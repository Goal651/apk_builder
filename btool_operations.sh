#!/usr/bin/env bash

# ========== BUNDLETOOL ========== #
download_bundletool() {
    log_info "Downloading bundletool ${BUNDLETOOL_VERSION}..."
    
    # Start download with progress
    echo -n "[*] Downloading... "
    
    if curl -L -o "${DEFAULT_BUNDLETOOL}" "${BUNDLETOOL_URL}" 2>/dev/null; then
        local file_size
        file_size=$(du -sh "${DEFAULT_BUNDLETOOL}" | cut -f1)
        echo -e "${GREEN}DONE${NC}"
        log_success "Download completed (${file_size})"
        log_debug "Location: $(pwd)/${DEFAULT_BUNDLETOOL}"
    else
        echo -e "${RED}FAILED${NC}"
        log_error "Failed to download bundletool!"
        log_error "URL: ${BUNDLETOOL_URL}"
        exit 1
    fi
}

locate_bundletool() {
    local found_path
    # First check current directory and common locations
    local search_paths=("./" "~/" "~/.local/bin/" "/usr/local/bin/")
    
    for path in "${search_paths[@]}"; do
        found_path=$(find "${path}" -maxdepth 1 -name "bundletool*.jar" 2>/dev/null | head -n 1)
        if [[ -n "${found_path}" ]]; then
            echo "${found_path}"
            return 0
        fi
    done
    
    log_warning "🔍 Bundletool not found in common locations, downloading..."
    download_bundletool
    echo "${DEFAULT_BUNDLETOOL}"
}

# ========== SELF-UPDATE ========== #
check_bundletool_updates() {
    log_info "Checking for bundletool updates..."
    
    # Get latest version from GitHub
    local latest_version
    latest_version=$(curl -s "https://api.github.com/repos/google/bundletool/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    
    if [[ -z "$latest_version" ]]; then
        log_warning "Could not check for updates"
        return 1
    fi
    
    # Remove 'v' prefix if present
    latest_version="${latest_version#v}"
    
    if [[ "$latest_version" != "$BUNDLETOOL_VERSION" ]]; then
        log_info "New bundletool version available: $latest_version (current: $BUNDLETOOL_VERSION)"
        
        if [[ "$INTERACTIVE" == true ]]; then
            echo -n "[?] Would you like to update bundletool? [y/N]: "
            read -r update_choice
            case "$update_choice" in
                [yY]|[yY][eE][sS])
                    update_bundletool "$latest_version"
                    ;;
                *)
                    log_info "Update cancelled"
                    ;;
            esac
        else
            log_info "Run with --interactive to update bundletool"
        fi
    else
        log_success "Bundletool is up to date ($BUNDLETOOL_VERSION)"
    fi
}

update_bundletool() {
    local new_version="$1"
    log_info "Updating bundletool to version $new_version..."
    
    # Backup current version
    if [[ -f "$DEFAULT_BUNDLETOOL" ]]; then
        mv "$DEFAULT_BUNDLETOOL" "${DEFAULT_BUNDLETOOL}.backup"
        log_info "Backed up current version"
    fi
    
    # Update constants for new version
    BUNDLETOOL_VERSION="$new_version"
    BUNDLETOOL_URL="https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar"
    DEFAULT_BUNDLETOOL="./bundletool-all-${BUNDLETOOL_VERSION}.jar"
    
    # Download new version
    if download_bundletool; then
        log_success "Bundletool updated successfully to $new_version"
        
        # Remove backup
        if [[ -f "${DEFAULT_BUNDLETOOL}.backup" ]]; then
            rm -f "${DEFAULT_BUNDLETOOL}.backup"
            log_info "Removed backup file"
        fi
        
        # Update config with new version
        save_config
    else
        log_error "Failed to update bundletool"
        # Restore backup
        if [[ -f "${DEFAULT_BUNDLETOOL}.backup" ]]; then
            mv "${DEFAULT_BUNDLETOOL}.backup" "$DEFAULT_BUNDLETOOL"
            log_info "Restored backup version"
        fi
        return 1
    fi
}
