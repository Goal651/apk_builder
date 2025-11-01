#!/usr/bin/env bash

# ========== KEYSTORE ========== #
create_keystore() {
    local ks_path="$1"
    local ks_alias="$2"
    local ks_pass="$3"
    
    if [[ -f "$ks_path" ]]; then
        log_info "Keystore already exists: $ks_path"
        # Validate existing keystore
        if validate_keystore "$ks_path" "$ks_alias" "$ks_pass"; then
            log_success "Keystore validation passed"
            return 0
        else
            log_warning "Existing keystore is invalid, recreating..."
        fi
    fi
    
    log_info "Creating keystore: $ks_path"
    
    # Ensure keystore directory exists
    local ks_dir
    ks_dir=$(dirname "$ks_path")
    if [[ ! -d "$ks_dir" ]]; then
        if ! mkdir -p "$ks_dir" 2>/dev/null; then
            log_error "Cannot create keystore directory: $ks_dir"
            return 1
        fi
    fi
    
    # Default dname
    local dname="CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown"
    
    if [[ "$INTERACTIVE" == true ]]; then
        echo -e "${GREEN}"
        echo "=[ KEYSTORE CONFIGURATION ]="
        echo "+ --- --=[ Certificate Information ]=-- --- +"
        echo -e "${NC}"
        echo -e "${CYAN}[*] This information will be used to create your app signing certificate${NC}"
        echo -e "${CYAN}[*] Press Enter to use default values shown in brackets${NC}"
        echo ""
        
        echo -n "[?] Your name or company name [Unknown]: "
        read -r cn
        cn="${cn:-Unknown}"
        
        echo -n "[?] Department or team name [Unknown]: "
        read -r ou
        ou="${ou:-Unknown}"
        
        echo -n "[?] Company or organization name [Unknown]: "
        read -r o
        o="${o:-Unknown}"
        
        echo -n "[?] City or locality [Unknown]: "
        read -r l
        l="${l:-Unknown}"
        
        echo -n "[?] State or province [Unknown]: "
        read -r st
        st="${st:-Unknown}"
        
        echo -n "[?] Country code (2 letters, e.g., US, GB) [Unknown]: "
        read -r c
        c="${c:-Unknown}"
        
        dname="CN=$cn, OU=$ou, O=$o, L=$l, ST=$st, C=$c"
        echo ""
        log_info "Certificate details configured"
    fi
    
    if ! keytool -genkeypair -v -keystore "$ks_path" -alias "$ks_alias" -keyalg RSA -keysize 2048 -validity 10000 -storepass "$ks_pass" -keypass "$ks_pass" -dname "$dname" 2>&1; then
        log_error "Failed to create keystore"
        return 1
    fi
    
    log_success "Keystore created successfully"
    # Validate the newly created keystore
    validate_keystore "$ks_path" "$ks_alias" "$ks_pass"
}

validate_keystore() {
    local ks_path="$1"
    local ks_alias="$2"
    local ks_pass="$3"
    
    if [[ ! -f "$ks_path" ]]; then
        log_error "Keystore file not found: $ks_path"
        return 1
    fi
    
    if ! keytool -list -keystore "$ks_path" -storepass "$ks_pass" -alias "$ks_alias" >/dev/null 2>&1; then
        log_error "Keystore validation failed - invalid keystore, alias, or password"
        return 1
    fi
    
    log_success "Keystore validation passed"
    return 0
}
