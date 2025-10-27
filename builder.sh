#!/usr/bin/env bash
# AAB to APKS Converter Tool - Professional CLI Edition
# Created by Wilson Goal
# Version 2.0 - 2025

set -o errexit  # Exit on error
set -o nounset  # Exit on unset variables
set -o pipefail # Catch pipe fails

# ========== CONSTANTS ========== #
readonly VERSION="2.0"
readonly BUNDLETOOL_VERSION="1.18.2"
readonly BUNDLETOOL_URL="https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar"
readonly DEFAULT_BUNDLETOOL="./bundletool-all-${BUNDLETOOL_VERSION}.jar"

# ========== DEFAULT CONFIG ========== #
VERBOSE=false
INTERACTIVE=true
OUTPUT_DIR="."
KEYSTORE_PATH="my-release-key.keystore"
KEYSTORE_ALIAS="my-key-alias"
KEYSTORE_PASS="123456"
BUILD_MODE="universal"
LOG_FILE=""

# ========== COLOR OUTPUT ========== #
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# ========== LOGGING ========== #
log_info() {
    [[ "$VERBOSE" == true ]] && echo -e "${BLUE}${BOLD}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}${BOLD}[ERROR]${NC} $1" >&2
}

log_debug() {
    [[ "$VERBOSE" == true ]] && echo -e "${MAGENTA}${BOLD}[DEBUG]${NC} $1"
}

# ========== HEADER & HELP ========== #
show_header() {
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║       🌟 Wilson Goal's AAB Converter Tool v${VERSION} 🌟          ║"
    echo "║          Professional Android App Bundle CLI Tool                ║"
    echo "║     Cross-platform • User-friendly • Feature-rich                 ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_help() {
    cat << 'EOF'
Usage: builder.sh [OPTIONS] [COMMAND]

Professional AAB to APKS converter with cross-platform support.

COMMANDS:
    convert     Convert AAB files to APKs (default)
    validate    Validate AAB bundle integrity
    info        Show AAB file information
    help        Show this help message

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -i, --interactive       Interactive mode (default)
    -n, --non-interactive   Non-interactive mode
    -o, --output DIR        Output directory (default: current)
    -k, --keystore PATH     Keystore file path
    -a, --alias ALIAS       Keystore alias
    -p, --password PASS     Keystore password
    -m, --mode MODE         Build mode: universal, system, persistent (default: universal)
    -l, --log FILE          Log output to file
    -V, --version           Show version information

EXAMPLES:
    builder.sh                              # Interactive conversion
    builder.sh --non-interactive           # Batch conversion
    builder.sh --output ./apks --verbose   # Verbose with custom output
    builder.sh validate                    # Validate bundles
    builder.sh info                        # Show bundle info

Created by Wilson Goal - 2025
EOF
}

show_version() {
    echo "Wilson Goal's AAB Converter v${VERSION}"
    echo "Bundletool version: ${BUNDLETOOL_VERSION}"
    echo "Built for cross-platform usage"
}

# ========== UTILITIES ========== #
check_dependencies() {
    command -v java >/dev/null 2>&1 || {
        log_error "Java is required but not installed. Please install Java 8+"
        exit 1
    }
    
    command -v curl >/dev/null 2>&1 || {
        log_error "curl is required but not installed. Please install curl"
        exit 1
    }
}

setup_logging() {
    if [[ -n "$LOG_FILE" ]]; then
        exec > >(tee -a "$LOG_FILE") 2>&1
        log_info "Logging to: $LOG_FILE"
    fi
}

# ========== BUNDLETOOL ========== #
download_bundletool() {
    log_info "🌐 Downloading bundletool ${BUNDLETOOL_VERSION}..."
    if ! curl -# -L -o "${DEFAULT_BUNDLETOOL}" "${BUNDLETOOL_URL}"; then
        log_error "❌ Failed to download bundletool!"
        exit 1
    fi
    log_success "✅ Download completed"
}

locate_bundletool() {
    local found_path
    found_path=$(find ~/ -name "bundletool-all-*.jar" 2>/dev/null | head -n 1)
    
    if [[ -n "${found_path}" ]]; then
        log_info "🔍 Found bundletool at: ${found_path}"
        echo "${found_path}"
        return 0
    fi
    
    download_bundletool
    echo "${DEFAULT_BUNDLETOOL}"
}

# ========== AAB OPERATIONS ========== #
validate_aab() {
    local aab_file="$1"
    local bundletool_path="$2"
    
    log_info "🔍 Validating: ${aab_file}"
    if java -jar "${bundletool_path}" validate --bundle="${aab_file}"; then
        log_success "✅ Valid AAB: ${aab_file}"
        return 0
    else
        log_error "❌ Invalid AAB: ${aab_file}"
        return 1
    fi
}

show_aab_info() {
    local aab_file="$1"
    local bundletool_path="$2"
    
    log_info "📋 Bundle info: ${aab_file}"
    java -jar "${bundletool_path}" dump manifest --bundle="${aab_file}" | head -20
}

convert_aab() {
    local aab_file="$1"
    local bundletool_path="$2"
    
    log_info "📦 Processing: ${aab_file}"
    log_debug "File size: $(du -sh "${aab_file}" | cut -f1)"
    
    local app_name
    if [[ "$INTERACTIVE" == true ]]; then
        app_name=$(get_app_name)
    else
        app_name="${aab_file%.*}"
    fi
    
    local output_name="${OUTPUT_DIR}/${app_name}.apks"
    
    log_info "🔄 Converting to ${output_name}..."
    
    if java -jar "${bundletool_path}" build-apks \
        --bundle="${aab_file}" \
        --output="${output_name}" \
        --mode="${BUILD_MODE}" \
        --ks="${KEYSTORE_PATH}" \
        --ks-key-alias="${KEYSTORE_ALIAS}" \
        --ks-pass="pass:${KEYSTORE_PASS}" \
        --key-pass="pass:${KEYSTORE_PASS}"; then
        log_success "🎉 Created: ${output_name}"
        log_debug "Output size: $(du -sh "${output_name}" | cut -f1)"
    else
        log_error "💥 Conversion failed for ${aab_file}"
        return 1
    fi
}

get_app_name() {
    while true; do
        echo -e "${YELLOW}${BOLD}💡 Enter app name (without spaces/special chars): ${NC}"
        read -r app_name
        
        if [[ -z "${app_name}" ]]; then
            log_warning "App name cannot be empty"
        elif [[ ! "${app_name}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            log_warning "Invalid characters. Use only letters, numbers, underscores or hyphens"
        else
            echo "${app_name}"
            break
        fi
    done
}

# ========== MAIN COMMANDS ========== #
command_convert() {
    local bundletool_path
    bundletool_path=$(locate_bundletool)
    
    log_info "🔍 Checking AAB files..."
    local aab_files=(*.aab)
    
    if [[ ${#aab_files[@]} -eq 0 ]]; then
        log_error "🚫 No AAB files found in current directory"
        exit 1
    fi
    
    log_info "📁 Found ${#aab_files[@]} AAB file(s):"
    [[ "$VERBOSE" == true ]] && {
        echo -e "${BLUE}"
        ls -lh *.aab
        echo -e "${NC}"
    }
    
    for aab_file in "${aab_files[@]}"; do
        [[ -f "${aab_file}" ]] || continue
        convert_aab "${aab_file}" "${bundletool_path}"
    done
    
    log_success "🎊 All conversions completed successfully!"
}

command_validate() {
    local bundletool_path
    bundletool_path=$(locate_bundletool)
    
    log_info "🔍 Checking AAB files for validation..."
    local aab_files=(*.aab)
    
    if [[ ${#aab_files[@]} -eq 0 ]]; then
        log_error "🚫 No AAB files found in current directory"
        exit 1
    fi
    
    for aab_file in "${aab_files[@]}"; do
        [[ -f "${aab_file}" ]] || continue
        validate_aab "${aab_file}" "${bundletool_path}"
    done
    
    log_success "✅ Validation completed"
}

command_info() {
    local bundletool_path
    bundletool_path=$(locate_bundletool)
    
    log_info "📋 Showing AAB information..."
    local aab_files=(*.aab)
    
    if [[ ${#aab_files[@]} -eq 0 ]]; then
        log_error "🚫 No AAB files found in current directory"
        exit 1
    fi
    
    for aab_file in "${aab_files[@]}"; do
        [[ -f "${aab_file}" ]] || continue
        show_aab_info "${aab_file}" "${bundletool_path}"
        echo ""
    done
}

# ========== MAIN ========== #
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_header
                show_help
                exit 0
                ;;
            -V|--version)
                show_version
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -n|--non-interactive)
                INTERACTIVE=false
                shift
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -k|--keystore)
                KEYSTORE_PATH="$2"
                shift 2
                ;;
            -a|--alias)
                KEYSTORE_ALIAS="$2"
                shift 2
                ;;
            -p|--password)
                KEYSTORE_PASS="$2"
                shift 2
                ;;
            -m|--mode)
                BUILD_MODE="$2"
                shift 2
                ;;
            -l|--log)
                LOG_FILE="$2"
                shift 2
                ;;
            convert|validate|info|help)
                COMMAND="$1"
                shift
                break
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Set default command
    COMMAND="${COMMAND:-convert}"
    
    # Initialize
    check_dependencies
    setup_logging
    show_header
    
    # Create output directory if needed
    [[ "$OUTPUT_DIR" != "." ]] && mkdir -p "$OUTPUT_DIR"
    
    # Execute command
    case "$COMMAND" in
        convert)
            command_convert "$@"
            ;;
        validate)
            command_validate "$@"
            ;;
        info)
            command_info "$@"
            ;;
        help)
            show_help
            ;;
        *)
            log_error "Unknown command: $COMMAND"
            show_help
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}${BOLD}Thank you for using Wilson Goal's AAB Converter!${NC}"
}

# Entry point
main "$@"