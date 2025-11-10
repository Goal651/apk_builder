validate_aab() {
    local aab_file="$1"
    local bundletool_path="$2"
    
    log_info "🔍 Validating: ${aab_file}"
    
    # Check if file exists first
    if [[ ! -f "${aab_file}" ]]; then
        log_error "❌ File not found: ${aab_file}"
        return 1
    fi
    
    # Validate with bundletool and capture output
    local validation_output
    validation_output=$(java -jar "${bundletool_path}" validate --bundle="${aab_file}" 2>&1) || {
        log_error "❌ Validation failed for ${aab_file}"
        echo -e "${RED}${validation_output}${NC}"
        return 1
    }
    
    log_success "✅ Valid AAB: ${aab_file}"
    echo -e "${GREEN}${validation_output}${NC}"
    return 0
}

show_aab_info() {
    local aab_file="$1"
    local bundletool_path="$2"
    
    log_info "📋 Bundle info: ${aab_file}"
    
    # Check if file exists first
    if [[ ! -f "${aab_file}" ]]; then
        log_error "❌ File not found: ${aab_file}"
        return 1
    fi
    
    # Get manifest info and handle errors
    local manifest_output
    manifest_output=$(java -jar "${bundletool_path}" dump manifest --bundle="${aab_file}" 2>&1) || {
        log_error "❌ Failed to get manifest info for ${aab_file}"
        echo -e "${RED}${manifest_output}${NC}"
        return 1
    }
    
    echo -e "${CYAN}${manifest_output}${NC}" | head -20
    return 0
}

convert_aab() {
    local aab_file="$1"
    local bundletool_path="$2"
    
    log_info "📦 Processing: ${aab_file}"
    
    # Check if file exists first
    if [[ ! -f "${aab_file}" ]]; then
        log_error "❌ File not found: ${aab_file}"
        return 1
    fi
    
    log_debug "File size: $(du -sh "${aab_file}" | cut -f1)"
    
    local app_name
    if [[ "$INTERACTIVE" == true ]]; then
        echo -e "${GREEN}"
        echo "=[ APP CONFIGURATION ]="
        echo "+ --- --=[ Output Settings ]=-- --- +"
        echo -e "${NC}"
        
        while true; do
            echo -n "[?] Enter output app name (no spaces/special chars): "
            read -r app_name
        
            if [[ -z "${app_name}" ]]; then
                log_warning "App name cannot be empty"
            elif [[ ! "${app_name}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
                log_warning "Invalid characters. Use only letters, numbers, underscores or hyphens"
            else
                log_info "Output name set to: $app_name"
                break
            fi
        done
    else
        app_name="${aab_file%.*}"
    fi
    
    local output_name="${OUTPUT_DIR}/${app_name}.apks"
    
    # Ensure keystore exists
    if ! create_keystore "$KEYSTORE_PATH" "$KEYSTORE_ALIAS" "$KEYSTORE_PASS"; then
        return 1
    fi
    
    log_info "Converting AAB to APKS format..."
    
    # Create output directory if needed
    if [[ "$OUTPUT_DIR" != "." ]] && ! mkdir -p "$OUTPUT_DIR" 2>/dev/null; then
        log_error "Failed to create output directory: $OUTPUT_DIR"
        return 1
    fi
    
    echo -n "[*] Processing bundle... "
    
    # Convert with bundletool and capture output
    local conversion_output
    conversion_output=$(java -jar "${bundletool_path}" build-apks \
        --bundle="${aab_file}" \
        --output="${output_name}" \
        --mode="${BUILD_MODE}" \
        --ks="${KEYSTORE_PATH}" \
        --ks-key-alias="${KEYSTORE_ALIAS}" \
        --ks-pass="pass:${KEYSTORE_PASS}" \
        --key-pass="pass:${KEYSTORE_PASS}" 2>&1) || {
        echo -e "${RED}FAILED${NC}"
        log_error "Conversion failed for ${aab_file}"
        echo -e "${RED}${conversion_output}${NC}"
        return 1
    }
    
    echo -e "${GREEN}DONE${NC}"
    log_success "Created: ${output_name}"
    log_debug "Output size: $(du -sh "${output_name}" | cut -f1)"
    return 0
}
