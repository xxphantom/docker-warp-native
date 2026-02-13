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

is_warp_plus() {
    [ -f /etc/wireguard/wgcf-account.toml ] || return 1
    account_type=$(grep 'account_type' /etc/wireguard/wgcf-account.toml | cut -d'"' -f2)
    [ -n "$account_type" ] && [ "$account_type" = "plus" ]
}

echo ""
printf "\033[1;96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
printf "\033[1;96m  \033[0m \033[1;97mDocker\033[0m \033[1;36mWARP\033[0m \033[1;97mNative\033[0m\n"
printf "\033[2;37m   Cloudflare WARP in Docker Container\033[0m\n"
printf "\033[1;96m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
echo ""

# Upgrade from free to WARP+ if license provided
if [ -n "$WARP_LICENSE" ] && [ -f /etc/wireguard/warp.conf ] && ! is_warp_plus; then
    info "WARP+ license detected. Upgrading from free account..."
    warn "Re-registration required due to Cloudflare API limitations"
    if wg show warp >/dev/null 2>&1; then
        wg-quick down warp 2>/dev/null || true
    fi
    rm -f /etc/wireguard/warp.conf /etc/wireguard/wgcf-profile.conf /etc/wireguard/wgcf-account.toml
    ok "Old account removed, proceeding with WARP+ registration"
fi

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
    
    if [ -f wgcf-account.toml ]; then
        ok "Using existing WARP account"
    else
        info "Performing wgcf registration..."
        
        # Try registration with timeout and error handling  
        output=$(timeout 60 sh -c 'yes | wgcf register' 2>&1)
        ret=$?

        if [ $ret -ne 0 ]; then
            warn "wgcf register exited with code $ret"
            
            if echo "$output" | grep -q "500 Internal Server Error"; then
                warn "Cloudflare returned 500 Internal Server Error - this is known behavior"
            elif echo "$output" | grep -q "existing account detected"; then
                warn "Existing account detected but file missing - trying alternative method"
            fi
            
            info "Trying alternative registration method..."
            echo | wgcf register >/dev/null 2>&1 || true
            sleep 2
        fi

        # Check if account file was created
        if [ ! -f wgcf-account.toml ]; then
            error_exit "Registration failed: wgcf-account.toml file not created"
        fi

        ok "WARP account successfully registered"
    fi
    
    info "Generating WARP configuration..."
    wgcf generate || error_exit "Failed to generate WARP configuration"

    # Apply WARP+ license if provided
    if [ -n "$WARP_LICENSE" ]; then
        info "Applying WARP+ license..."
        if wgcf update --license-key "$WARP_LICENSE" 2>&1; then
            ok "WARP+ license applied successfully"
            info "Regenerating configuration with WARP+..."
            wgcf generate || error_exit "Failed to regenerate WARP+ configuration"
            ok "WARP+ configuration generated"
        else
            warn "Failed to apply WARP+ license. Check your key."
            info "Continuing with free WARP"
        fi
    fi

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
curl_result=$(curl -s --interface warp --max-time 5 https://www.cloudflare.com/cdn-cgi/trace | grep "warp=" | cut -d= -f2)
if [ "$curl_result" = "plus" ]; then
    ok "Cloudflare confirmed: warp=plus — WARP+ is active!"
elif [ "$curl_result" = "on" ]; then
    ok "Cloudflare confirmed: warp=on"
elif [ "$curl_result" = "off" ]; then
    warn "Cloudflare confirmed: warp=off"
else
    fail "Cloudflare did not respond in time"
fi

# Show account type from local config
if is_warp_plus; then
    ok "Account type: WARP+"
else
    info "Account type: Free"
fi

if is_warp_plus; then
    ok "WARP+ is ready!"
else
    ok "WARP is ready!"
fi
info "Container is running. WARP interface is active."

# Keep container running and handle signals
trap 'echo ""; info "Shutting down WARP..."; wg-quick down warp 2>/dev/null; ok "WARP shutdown"; exit 0' SIGTERM SIGINT

# Keep container running
tail -f /dev/null &
wait