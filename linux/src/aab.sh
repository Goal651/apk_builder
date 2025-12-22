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

command_convert() {
    local bundletool_path
    bundletool_path=$(locate_bundletool)
    log_info "🔍 Found bundletool at: ${bundletool_path}"
    
    log_info "🔍 Checking AAB files..."
    local aab_files=(../*.aab)
    
    if [[ ${#aab_files[@]} -eq 0 ]]; then
        log_error "🚫 No AAB files found in current directory"
        log_error "💡 Please place .aab files in $(pwd) and try again"
        exit 1
    fi
    
    log_info "📁 Found ${#aab_files[@]} AAB file(s):"
    if [[ ${#aab_files[@]} -gt 0 ]]; then
        echo -e "${BLUE}"
        ls -lh "${aab_files[@]}"
        echo -e "${NC}"
    fi
    
    local failed_count=0
    for aab_file in "${aab_files[@]}"; do
        [[ -f "${aab_file}" ]] || continue
        if ! convert_aab "${aab_file}" "${bundletool_path}"; then
            ((failed_count++))
        fi
    done
    
    if [[ $failed_count -eq 0 ]]; then
        log_success "🎊 All conversions completed successfully!"
    else
        log_warning "⚠️  Completed with $failed_count error(s)"
        exit 1
    fi
}



command_validate() {
    local bundletool_path
    bundletool_path=$(locate_bundletool)
    log_info "🔍 Found bundletool at: ${bundletool_path}"
    
    log_info "🔍 Checking AAB files for validation..."
    local aab_files=(*.aab)
    
    if [[ ${#aab_files[@]} -eq 0 ]]; then
        log_error "🚫 No AAB files found in current directory"
        log_error "💡 Please place .aab files in $(pwd) and try again"
        exit 1
    fi
    
    local failed_count=0
    for aab_file in "${aab_files[@]}"; do
        [[ -f "${aab_file}" ]] || continue
        if ! validate_aab "${aab_file}" "${bundletool_path}"; then
            ((failed_count++))
        fi
    done
    
    if [[ $failed_count -eq 0 ]]; then
        log_success "✅ Validation completed - All files valid!"
    else
        log_warning "⚠️  Validation completed with $failed_count invalid file(s)"
        exit 1
    fi
}

command_info() {
    local bundletool_path
    bundletool_path=$(locate_bundletool)
    log_info "🔍 Found bundletool at: ${bundletool_path}"
    
    log_info "📋 Showing AAB information..."
    local aab_files=(*.aab)
    
    if [[ ${#aab_files[@]} -eq 0 ]]; then
        log_error "🚫 No AAB files found in current directory"
        log_error "💡 Please place .aab files in $(pwd) and try again"
        exit 1
    fi
    
    local failed_count=0
    for aab_file in "${aab_files[@]}"; do
        [[ -f "${aab_file}" ]] || continue
        echo -e "${CYAN}${BOLD}═══════════════════════════════════════${NC}"
        if ! show_aab_info "${aab_file}" "${bundletool_path}"; then
            ((failed_count++))
        fi
        echo ""
    done
    
    if [[ $failed_count -eq 0 ]]; then
        log_success "✅ Information displayed for all files"
    else
        log_warning "⚠️  Could not get info for $failed_count file(s)"
        exit 1
    fi
}

command_batch() {
    echo -e "${GREEN}"
    echo "=[ BATCH PROCESSING MODE ]="
    echo "+ --- --=[ Queue Management ]=-- --- +"
    echo -e "${NC}"
    
    local bundletool_path
    bundletool_path=$(locate_bundletool)
    log_info "Found bundletool at: ${bundletool_path}"
    
    log_info "Scanning for AAB files..."
    local aab_files=(*.aab)
    
    if [[ ${#aab_files[@]} -eq 0 ]]; then
        log_error "No AAB files found in current directory"
        log_error "Place .aab files in $(pwd) and try again"
        exit 1
    fi
    
    log_info "Found ${#aab_files[@]} file(s) in queue"
    
    local processed=0
    local successful=0
    local failed=0
    local start_time=$(date +%s)
    
    for aab_file in "${aab_files[@]}"; do
        [[ -f "${aab_file}" ]] || continue
        ((processed++))
        
        log_info "Processing [$processed/${#aab_files[@]}]: ${aab_file}"
        
        if convert_aab "${aab_file}" "${bundletool_path}"; then
            ((successful++))
            log_success "Completed: ${aab_file}"
        else
            ((failed++))
            log_error "Failed: ${aab_file}"
        fi
        
        # Show progress
        local percentage=$((processed * 100 / ${#aab_files[@]}))
        echo -e "${BLUE}[*] Progress: $processed/${#aab_files[@]} files ($percentage%)${NC}"
        echo ""
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo -e "${GREEN}"
    echo "=[ BATCH PROCESSING COMPLETE ]="
    echo "+ --- --=[ Statistics ]=-- --- +"
    echo -e "${NC}"
    log_info "Total files processed: $processed"
    log_success "Successful conversions: $successful"
    if [[ $failed -gt 0 ]]; then
        log_warning "Failed conversions: $failed"
    fi
    log_info "Total time: ${duration}s"
    log_info "Average time per file: $((duration / processed))s"
}
