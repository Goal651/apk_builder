#!/usr/bin/env bash
# AAB to APKS Converter Tool - Linux CLI Edition
# Created by Wilson Goal
# Version 2.0 - 2025
# Optimized for Ubuntu/Debian-based Linux distributions

set -o errexit  # Exit on error
set -o nounset  # Exit on unset variables
set -o pipefail # Catch pipe fails
shopt -s nullglob # Ensure globs expand to empty array when no matches

# ========== CONSTANTS ========== #
readonly VERSION="1.0.1"
readonly BUNDLETOOL_VERSION="1.18.2"
readonly BUNDLETOOL_URL="https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar"
readonly DEFAULT_BUNDLETOOL="./bundletool-all-${BUNDLETOOL_VERSION}.jar"

# ========== DEFAULT CONFIG ========== #
VERBOSE=true
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
    echo -e "${BLUE}${BOLD}[INFO]${NC} $1"
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
    echo -e "${MAGENTA}${BOLD}[DEBUG]${NC} $1"
}

# ========== HEADER & HELP ========== #
show_header() {
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║       🌟 Wilson Goal's AAB Converter Tool v${VERSION} 🌟          ║"
    echo "║          Linux-Optimized Android App Bundle CLI Tool         ║"
    echo "║     Ubuntu/Debian • Auto-deps • User-friendly • Feature-rich  ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_help() {
    cat << 'EOF'
Usage: builder.sh [OPTIONS] [COMMAND]

Linux-optimized AAB to APKS converter with automatic dependency management.

COMMANDS:
    convert     Convert AAB files to APKs (default)
    validate    Validate AAB bundle integrity
    info        Show AAB file information
    help        Show this help message

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
    - Java Runtime Environment (JRE 8+)
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

# ========== UTILITIES ========== #
check_dependencies() {
    echo -e "${CYAN}${BOLD}🔍 Checking Dependencies...${NC}"
    
    local missing_deps=()
    local install_commands=()
    
    # Check Java
    echo -n "  • Java Runtime Environment... "
    if ! command -v java >/dev/null 2>&1; then
        echo -e "${RED}❌ Missing${NC}"
        missing_deps+=("Java Runtime Environment (JRE 8+)")
        install_commands+=("sudo apt update && sudo apt install -y openjdk-11-jre")
    else
        local java_version
        java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
        echo -e "${GREEN}✅ Found (${java_version})${NC}"
    fi
    
    # Check curl
    echo -n "  • curl... "
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}❌ Missing${NC}"
        missing_deps+=("curl")
        install_commands+=("sudo apt update && sudo apt install -y curl")
    else
        local curl_version
        curl_version=$(curl --version 2>/dev/null | head -n1 | cut -d' ' -f2)
        echo -e "${GREEN}✅ Found (${curl_version})${NC}"
    fi
    
    # Check find
    echo -n "  • find utility... "
    if ! command -v find >/dev/null 2>&1; then
        echo -e "${RED}❌ Missing${NC}"
        missing_deps+=("findutils")
        install_commands+=("sudo apt update && sudo apt install -y findutils")
    else
        echo -e "${GREEN}✅ Found${NC}"
    fi
    
    # Check du
    echo -n "  • disk utility (du)... "
    if ! command -v du >/dev/null 2>&1; then
        echo -e "${RED}❌ Missing${NC}"
        missing_deps+=("coreutils")
        install_commands+=("sudo apt update && sudo apt install -y coreutils")
    else
        echo -e "${GREEN}✅ Found${NC}"
    fi
    
    # Check bundletool
    echo -n "  • Bundletool jar... "
    local bundletool_found
    bundletool_found=$(find ./ ~/ ~/.local/bin/ /usr/local/bin/ -maxdepth 1 -name "bundletool*.jar" 2>/dev/null | head -n1)
    if [[ -z "$bundletool_found" || ! -f "$bundletool_found" ]]; then
        echo -e "${RED}❌ Missing${NC}"
        missing_deps+=("Bundletool ${BUNDLETOOL_VERSION}")
        install_commands+=("download_bundletool")
    else
        echo -e "${GREEN}✅ Found ($(basename "$bundletool_found"))${NC}"
    fi
    
    echo ""
    
    # If no missing dependencies, return success
    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        log_success "🎉 All dependencies satisfied!"
        return 0
    fi
    
    # Show missing dependencies
    echo -e "${YELLOW}${BOLD}⚠️  Missing Dependencies Detected:${NC}"
    echo -e "${RED}"
    for i in "${!missing_deps[@]}"; do
        echo "  - ${missing_deps[$i]}"
    done
    echo -e "${NC}"
    
    # Show what will be done
    echo -e "${CYAN}${BOLD}📋 Actions to be taken:${NC}"
    echo -e "${BLUE}"
    for i in "${!missing_deps[@]}"; do
        local dep="${missing_deps[$i]}"
        local cmd="${install_commands[$i]}"
        if [[ "$cmd" == "download_bundletool" ]]; then
            echo "  - Download Bundletool ${BUNDLETOOL_VERSION} from GitHub"
        else
            echo "  - Install: $cmd"
        fi
    done
    echo -e "${NC}"
    
    # Ask for confirmation
    if [[ "$INTERACTIVE" == true ]]; then
        echo -e "${YELLOW}${BOLD}🤔 Would you like me to automatically install/download these missing dependencies? [y/N]: ${NC}"
        read -r response
        case "$response" in
            [yY]|[yY][eE][sS])
                log_info "🔧 Installing missing dependencies..."
                echo ""
                
                for i in "${!missing_deps[@]}"; do
                    local dep="${missing_deps[$i]}"
                    local cmd="${install_commands[$i]}"
                    
                    echo -e "${BLUE}➤ Processing: $dep${NC}"
                    
                    if [[ "$cmd" == "download_bundletool" ]]; then
                        download_bundletool
                    else
                        log_debug "Executing: $cmd"
                        if eval "$cmd"; then
                            log_success "✅ $dep installed successfully"
                        else
                            log_error "❌ Failed to install $dep"
                            log_error "💡 Please run manually: $cmd"
                            exit 1
                        fi
                    fi
                    echo ""
                done
                
                # Final verification
                log_info "🔍 Final verification..."
                local still_missing=()
                for dep in "${missing_deps[@]}"; do
                    case "$dep" in
                        *"Java"*) 
                            if ! command -v java >/dev/null 2>&1; then
                                still_missing+=("$dep")
                            fi
                            ;;
                        *"curl"*) 
                            if ! command -v curl >/dev/null 2>&1; then
                                still_missing+=("$dep")
                            fi
                            ;;
                        *"find"*) 
                            if ! command -v find >/dev/null 2>&1; then
                                still_missing+=("$dep")
                            fi
                            ;;
                        *"coreutils"*) 
                            if ! command -v du >/dev/null 2>&1; then
                                still_missing+=("$dep")
                            fi
                            ;;
                        *"Bundletool"*) 
                            local bt_check
                            bt_check=$(find ./ ~/ ~/.local/bin/ /usr/local/bin/ -maxdepth 1 -name "bundletool*.jar" 2>/dev/null | head -n1)
                            if [[ -z "$bt_check" || ! -f "$bt_check" ]]; then
                                still_missing+=("$dep")
                            fi
                            ;;
                    esac
                done
                
                if [[ ${#still_missing[@]} -eq 0 ]]; then
                    log_success "🎉 All dependencies installed successfully!"
                else
                    log_error "❌ Some dependencies still missing: ${still_missing[*]}"
                    exit 1
                fi
                ;;
            *)
                log_error "❌ Cannot proceed without required dependencies"
                log_error "💡 Please install them manually and run the script again"
                exit 1
                ;;
        esac
    else
        log_error "❌ Missing dependencies detected in non-interactive mode"
        log_error "💡 Please install manually: ${missing_deps[*]}"
        exit 1
    fi
}

setup_logging() {
    if [[ -n "$LOG_FILE" ]]; then
        # Create log file directory if needed
        local log_dir
        log_dir=$(dirname "$LOG_FILE")
        if [[ ! -d "$log_dir" ]]; then
            if ! mkdir -p "$log_dir" 2>/dev/null; then
                log_error "Cannot create log directory: $log_dir"
                exit 1
            fi
        fi
        
        # Test write permissions
        if ! touch "$LOG_FILE" 2>/dev/null; then
            log_error "Cannot write to log file: $LOG_FILE"
            exit 1
        fi
        
        # Redirect stdout and stderr to log file while preserving console output
        exec 1> >(tee -a "$LOG_FILE")
        exec 2> >(tee -a "$LOG_FILE" >&2)
        log_info "Logging to: $LOG_FILE"
    fi
}

# ========== BUNDLETOOL ========== #
download_bundletool() {
    log_info "🌐 Downloading bundletool ${BUNDLETOOL_VERSION}..."
    log_debug "📡 URL: ${BUNDLETOOL_URL}"
    log_debug "💾 Target: ${DEFAULT_BUNDLETOOL}"
    
    # Show download progress
    if curl --progress-bar -L -o "${DEFAULT_BUNDLETOOL}" "${BUNDLETOOL_URL}"; then
        local file_size
        file_size=$(du -sh "${DEFAULT_BUNDLETOOL}" | cut -f1)
        log_success "✅ Download completed (${file_size})"
        log_debug "📍 Location: $(pwd)/${DEFAULT_BUNDLETOOL}"
    else
        log_error "❌ Failed to download bundletool!"
        log_error "🔗 Please check: ${BUNDLETOOL_URL}"
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
            log_info "🔍 Found bundletool at: ${found_path}"
            echo "${found_path}"
            return 0
        fi
    done
    
    log_warning "🔍 Bundletool not found in common locations, downloading..."
    download_bundletool
    echo "${DEFAULT_BUNDLETOOL}"
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
        app_name=$(get_app_name)
    else
        app_name="${aab_file%.*}"
    fi
    
    local output_name="${OUTPUT_DIR}/${app_name}.apks"
    
    log_info "🔄 Converting to ${output_name}..."
    
    # Create output directory if needed
    if [[ "$OUTPUT_DIR" != "." ]] && ! mkdir -p "$OUTPUT_DIR" 2>/dev/null; then
        log_error "❌ Failed to create output directory: $OUTPUT_DIR"
        return 1
    fi
    
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
        log_error "💥 Conversion failed for ${aab_file}"
        echo -e "${RED}${conversion_output}${NC}"
        return 1
    }
    
    log_success "🎉 Created: ${output_name}"
    log_debug "Output size: $(du -sh "${output_name}" | cut -f1)"
    echo -e "${GREEN}${conversion_output}${NC}"
    return 0
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
                log_info "📢 Verbose mode enabled"
                shift
                ;;
            --quiet)
                VERBOSE=false
                log_info "🔇 Quiet mode enabled"
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
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Output directory cannot be empty or start with '-'"
                    exit 1
                fi
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -k|--keystore)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Keystore path cannot be empty or start with '-'"
                    exit 1
                fi
                KEYSTORE_PATH="$2"
                shift 2
                ;;
            -a|--alias)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Keystore alias cannot be empty or start with '-'"
                    exit 1
                fi
                KEYSTORE_ALIAS="$2"
                shift 2
                ;;
            -p|--password)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Password cannot be empty or start with '-'"
                    exit 1
                fi
                KEYSTORE_PASS="$2"
                shift 2
                ;;
            -m|--mode)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Build mode cannot be empty or start with '-'"
                    exit 1
                fi
                if [[ ! "$2" =~ ^(universal|system|persistent)$ ]]; then
                    log_error "Invalid build mode: $2. Use: universal, system, or persistent"
                    exit 1
                fi
                BUILD_MODE="$2"
                shift 2
                ;;
            -l|--log)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Log file path cannot be empty or start with '-'"
                    exit 1
                fi
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