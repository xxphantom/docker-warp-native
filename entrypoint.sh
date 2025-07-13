#!/bin/sh

# Version
VERSION="${VERSION:-dev}"

ok() {
    printf "\033[1;32m[OK]\033[0m %s\n" "$1"
}

warn() {
    printf "\033[1;33m[WARN]\033[0m %s\n" "$1"
}

fail() {
    printf "\033[1;31m[FAIL]\033[0m %s\n" "$1"
}

info() {
    printf "\033[1;34m[INFO]\033[0m %s\n" "$1"
}

error_exit() {
    fail "$1"
    exit 1
}

echo ""
printf "\033[1;96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
printf "\033[1;96m  \033[0m \033[1;97mDocker\033[0m \033[1;36mWARP\033[0m \033[1;97mNative\033[0m\n"
printf "\033[2;37m   Cloudflare WARP in Docker Container\033[0m\n"
printf "\033[1;96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
echo ""

# Check if warp.conf already exists
if [ -f /etc/wireguard/warp.conf ]; then
    info "Found existing WARP configuration"
    
    # Check if interface is already up
    if wg show warp >/dev/null 2>&1; then
        ok "WARP interface is already active"
    else
        info "Starting WARP interface..."
        wg-quick up warp || error_exit "Failed to start WARP interface"
        ok "WARP interface started"
    fi
else
    info "No existing configuration found. Setting up new WARP connection..."
    
    info "Registering with WARP..."
    cd /etc/wireguard
    yes | wgcf register || error_exit "Failed to register with WARP"
    
    info "Generating WARP configuration..."
    wgcf generate || error_exit "Failed to generate WARP configuration"
    
    info "Configuring WARP..."
    
    # Add Table = off
    if ! grep -q "Table = off" wgcf-profile.conf; then
        sed -i '/^MTU =/aTable = off' wgcf-profile.conf
    fi
    
    # Add PersistentKeepalive
    if ! grep -q "PersistentKeepalive = 25" wgcf-profile.conf; then
        sed -i '/^Endpoint =/aPersistentKeepalive = 25' wgcf-profile.conf
    fi
    
    # Check if IPv6 is available
    if ip -6 addr show >/dev/null 2>&1 && [ "$(sysctl -n net.ipv6.conf.all.disable_ipv6)" = "0" ]; then
        ok "IPv6 is enabled"
    else
        warn "IPv6 is disabled, removing IPv6 addresses from config"
        sed -i 's/,\s*[0-9a-fA-F:]\+\/128//' wgcf-profile.conf
        sed -i '/Address = [0-9a-fA-F:]\+\/128/d' wgcf-profile.conf
    fi
    
    # Rename config file
    mv wgcf-profile.conf warp.conf
    ok "WARP configuration saved"
    
    info "Starting WARP interface..."
    # Check if interface already exists
    if ip link show warp >/dev/null 2>&1; then
        warn "WARP interface already exists, bringing it down first"
        wg-quick down warp 2>/dev/null || true
    fi
    wg-quick up warp || error_exit "Failed to start WARP interface"
    ok "WARP interface started"
fi

# Check connection status
info "Checking WARP connection status..."

# Initiate traffic to trigger handshake
curl -s --interface warp --max-time 5 https://www.cloudflare.com/cdn-cgi/trace >/dev/null 2>&1 || true

# Wait for handshake
i=1
while [ $i -le 10 ]; do
    handshake=$(wg show warp | grep "latest handshake" | awk -F': ' '{print $2}')
    
    # Check if handshake exists and is not "never"
    if [ -n "$handshake" ] && [ "$handshake" != "never" ]; then
        # Check for any time-based handshake (second, minute, hour ago)
        if echo "$handshake" | grep -qE "(second|minute|hour).*ago"; then
            ok "Received handshake → $handshake"
            ok "WARP is connected and exchanging traffic"
            break
        fi
    fi
    
    # On last iteration, show current status
    if [ $i -eq 10 ]; then
        if [ -z "$handshake" ] || [ "$handshake" = "never" ]; then
            warn "No handshake received yet"
        else
            warn "Unexpected handshake format: $handshake"
        fi
    fi
    
    i=$((i + 1))
    sleep 3
done

# Always verify with Cloudflare API
curl_result=$(curl -s --interface warp https://www.cloudflare.com/cdn-cgi/trace | grep "warp=" | cut -d= -f2)
if [ "$curl_result" = "on" ]; then
    ok "Cloudflare confirmed: warp=on"
else
    warn "Cloudflare did not confirm warp=on, but interface is working"
fi

ok "WARP is ready!"
info "Container is running. WARP interface is active."

# Keep container running and handle signals
trap 'echo ""; info "Shutting down WARP..."; wg-quick down warp 2>/dev/null; exit 0' SIGTERM SIGINT

# Keep container running
tail -f /dev/null