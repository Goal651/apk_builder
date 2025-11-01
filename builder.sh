#!/usr/bin/env bash

# Source component files
source "./config.sh"
source "./functions.sh"
source "./btool_operations.sh"
source "./keystore.sh"

set -o errexit  # Exit on error
set -o nounset  # Exit on unset variables
set -o pipefail # Catch pipe fails
shopt -s nullglob # Ensure globs expand to empty array when no matches

# Initialize theme
set_theme

# ========== CONFIGURATION ========== #
load_config() {
    local config_file="${HOME}/.aab-converter.conf"
    if [[ -f "$config_file" ]]; then
        log_info "Loading configuration from $config_file"
        source "$config_file"
    fi
}

save_config() {
    local config_file="${HOME}/.aab-converter.conf"
    log_info "Saving configuration to $config_file"
    
    cat > "$config_file" << EOF
# AAB Converter Configuration
# Generated automatically - edit with caution

VERBOSE=${VERBOSE:-true}
INTERACTIVE=${INTERACTIVE:-true}
OUTPUT_DIR="${OUTPUT_DIR:-.}"
KEYSTORE_PATH="${KEYSTORE_PATH:-my-release-key.keystore}"
KEYSTORE_ALIAS="${KEYSTORE_ALIAS:-my-key-alias}"
BUILD_MODE="${BUILD_MODE:-universal}"
SECURE_INPUT=${SECURE_INPUT:-false}
THEME="${THEME:-msf}"
EOF
}

# ========== HEADER & HELP ========== #
show_header() {
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                              ║"
    echo "║  █████╗  █████╗ ██████╗      █████╗ ██████╗ ██████╗  █████╗ ███████╗███████╗  ║"
    echo "║ ██╔══██╗██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝  ║"
    echo "║ ███████║███████║██████╔╝    ███████║██████╔╝██████╔╝███████║█████╗  ███████╗  ║"
    echo "║ ██╔══██║██╔══██║██╔══██╗    ██╔══██║██╔══██╗██╔══██╗██╔══██║██╔══╝  ╚════██║  ║"
    echo "║ ██║  ██║██║  ██║██████╔╝    ██║  ██║██████╔╝██████╔╝██║  ██║███████╗███████║  ║"
    echo "║ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝     ╚═╝  ╚═╝╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝  ║"
    echo "║                                                                              ║"
    echo "║  ██████╗ ██████╗ ███╗   ██╗██╗   ██╗███████╗██████╗ ████████╗ ██████╗ ██████╗ ║"
    echo "║ ██╔════╝██╔═══██╗████╗  ██║██║   ██║██╔════╝██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗║"
    echo "║ ██║     ██║   ██║██╔██╗ ██║██║   ██║█████╗  ██████╔╝   ██║   ██║   ██║██████╔╝║"
    echo "║ ██║     ██║   ██║██║╚██╗██║╚██╗ ██╔╝██╔══╝  ██╔══██╗   ██║   ██║   ██║██╔══██╗║"
    echo "║ ╚██████╗╚██████╔╝██║ ╚████║ ╚████╔╝ ███████╗██║  ██║   ██║   ╚██████╔╝██║  ██║║"
    echo "║  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝║"
    echo "║                                                                              ║"
    echo "║                     LINUX CLI EDITION • v${VERSION} • 2025                     ║"
    echo "║                                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}                 =[ AAB to APKS Converter • Wilson Goal ]=${NC}"
    echo -e "${GREEN}                 + --- --=[ Bundletool v${BUNDLETOOL_VERSION} ]=-- --- +${NC}"
    echo -e "${GREEN}                 + --- --=[ ${BUILD_MODE} Mode • ${THEME} Theme ]=-- --- +${NC}"
    echo ""
}

show_help() {
    cat << 'EOF'
Usage: builder.sh [OPTIONS] [COMMAND]

Linux-optimized AAB to APKS converter with automatic dependency management.

COMMANDS:
    convert     Convert AAB files to APKs (default)
    validate    Validate AAB bundle integrity
    info        Show AAB file information
    batch       Batch process multiple files with queue management
    cleanup     Remove temporary and generated files
    update      Check for and update bundletool
    examples    Show usage examples

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output (default)
    --quiet                 Disable verbose output
    -i, --interactive       Interactive mode (default)
    -n, --non-interactive   Non-interactive mode
    -o, --output DIR        Output directory (default: current)
    -k, --keystore PATH     Keystore file path
    -a, --alias ALIAS       Keystore alias
    -p, --password PASS     Keystore password
    --secure                Use secure (hidden) password input
    --theme THEME           Color theme: msf, dark, light, minimal (default: msf)
    -m, --mode MODE         Build mode: universal, system, persistent (default: universal)
    -l, --log FILE          Log output to file
    -V, --version           Show version information

EXAMPLES:
    builder.sh                             # Interactive conversion (verbose)
    builder.sh --quiet                     # Silent conversion
    builder.sh --non-interactive           # Batch conversion
    builder.sh --output ./apks --verbose   # Verbose with custom output
    builder.sh validate                    # Validate bundles
    builder.sh info                        # Show bundle info

REQUIREMENTS:
    - Ubuntu/Debian-based Linux distribution
    - Java Development Kit (JDK 8+)
    - curl, findutils, coreutils
    - Internet connection for bundletool download

Created by Wilson Goal - 2025
EOF
}

show_version() {
    echo "Wilson Goal's AAB Converter v${VERSION}"
    echo "Bundletool version: ${BUNDLETOOL_VERSION}"
    echo "Optimized for Ubuntu/Debian Linux distributions"
}

# ========== AAB OPERATIONS ========== #
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

# ========== MAIN COMMANDS ========== #
command_convert() {
    local bundletool_path
    bundletool_path=$(locate_bundletool)
    log_info "🔍 Found bundletool at: ${bundletool_path}"
    
    log_info "🔍 Checking AAB files..."
    local aab_files=(*.aab)
    
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
    
    log_info "📁 Found ${#aab_files[@]} AAB file(s):"
    if [[ ${#aab_files[@]} -gt 0 ]]; then
        echo -e "${BLUE}"
        ls -lh "${aab_files[@]}"
        echo -e "${NC}"
    fi
    
    local failed_count=0
    for aab_file in "${aab_files[@]}"; do
        [[ -f "${aab_file}" ]] || continue
        if ! validate_aab "${aab_file}" "${bundletool_path}"; then
            ((failed_count++))
        fi
    done
    
    if [[ $failed_count -eq 0 ]]; then
        log_success "🎊 All validations passed successfully!"
    else
        log_warning "⚠️  Completed with $failed_count error(s)"
        exit 1
    fi
}