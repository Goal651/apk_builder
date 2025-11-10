#!/usr/bin/env bash
# AAB to APKS Converter Tool - Linux CLI Edition
# Created by Wilson Goal
# Version 2.0 - 2025
# Optimized for Ubuntu/Debian-based Linux distributions
set -o errexit  # Exit on error
set -o nounset  # Exit on unset variables
set -o pipefail # Catch pipe fails
shopt -s nullglob # Ensure globs expand to empty array when no matches

source './aab_func.sh'
source './btool_operations.sh'
source './constant.sh'
source './functions.sh'
source './header_temp.sh'
source './help.sh'
source './keystore.sh'
source './theme.sh'


# ========== LOGGING ========== #
log_info() {
    echo -e "${BLUE}[*]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[-]${NC} $1" >&2
}

log_debug() {
    echo -e "${MAGENTA}[DEBUG]${NC} $1"
}

# ========== HEADER & HELP ========== #

show_version() {
    echo "Wilson Goal's AAB Converter v${VERSION}"
    echo "Bundletool version: ${BUNDLETOOL_VERSION}"
    echo "Optimized for Ubuntu/Debian Linux distributions"
}

# ========== PROGRESS BAR ========== #
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    
    printf "\r[*] Progress: [%-${width}s] %d%% (%d/%d)" \
        "$(printf '█%.0s' $(seq 1 $completed))" \
        "$percentage" "$current" "$total"
}

show_spinner() {
    local pid=$1
    local message=$2
    local spin='|/-\'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        printf "\r[*] %s %c" "$message" "${spin:i++%${#spin}:1}"
        sleep 0.1
    done
    printf "\r[*] %s ✓\n" "$message"
}

# ========== UTILITIES ========== #
check_dependencies() {
    echo ""
    echo -e "${GREEN}=[ SYSTEM ANALYSIS ]=${NC}"
    echo -e "${GREEN}+ --- --=[ Dependency Check ]=-- --- +${NC}"
    echo ""
    
    local missing_deps=()
    local install_commands=()
    
    # Check Java with spinner
    echo -n "[*] Analyzing Java Development Kit... "
    # Simulate checking (java -version is fast, but we show spinner for UX)
    sleep 0.5 &
    local java_pid=$!
    show_spinner $java_pid "Java JDK"
    wait $java_pid
    
    if java -version >/dev/null 2>&1; then
        local java_version
        java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
        echo -e "${GREEN}FOUND (${java_version})${NC}"
    else
        echo -e "${RED}NOT FOUND${NC}"
        missing_deps+=("Java Development Kit (JDK 8+)")
        install_commands+=("sudo apt update && sudo apt install -y openjdk-11-jdk")
    fi
    
    # Check curl with spinner
    echo -n "[*] Analyzing curl utility... "
    sleep 0.3 &
    local curl_pid=$!
    show_spinner $curl_pid "curl"
    wait $curl_pid
    
    if command -v curl >/dev/null 2>&1; then
        local curl_version
        curl_version=$(curl --version 2>/dev/null | head -n1 | cut -d' ' -f2)
        echo -e "${GREEN}FOUND (${curl_version})${NC}"
    else
        echo -e "${RED}NOT FOUND${NC}"
        missing_deps+=("curl")
        install_commands+=("sudo apt update && sudo apt install -y curl")
    fi
    
    # Check find utility
    echo -n "[*] Analyzing find utility... "
    sleep 0.2 &
    local find_pid=$!
    show_spinner $find_pid "find"
    wait $find_pid
    
    if command -v find >/dev/null 2>&1; then
        echo -e "${GREEN}FOUND${NC}"
    else
        echo -e "${RED}NOT FOUND${NC}"
        missing_deps+=("findutils")
        install_commands+=("sudo apt update && sudo apt install -y findutils")
    fi
    
    # Check disk utility
    echo -n "[*] Analyzing disk utility... "
    sleep 0.2 &
    local du_pid=$!
    show_spinner $du_pid "du"
    wait $du_pid
    
    if command -v du >/dev/null 2>&1; then
        echo -e "${GREEN}FOUND${NC}"
    else
        echo -e "${RED}NOT FOUND${NC}"
        missing_deps+=("coreutils")
        install_commands+=("sudo apt update && sudo apt install -y coreutils")
    fi
    
    # Check bundletool (this one takes longer, so real spinner)
    echo -n "[*] Analyzing Bundletool... "
    find ./ ~/ ~/.local/bin/ /usr/local/bin/ -maxdepth 1 -name "bundletool*.jar" >/dev/null 2>&1 &
    local bundletool_pid=$!
    show_spinner $bundletool_pid "Bundletool"
    wait $bundletool_pid
    
    local bundletool_found
    bundletool_found=$(find ./ ~/ ~/.local/bin/ /usr/local/bin/ -maxdepth 1 -name "bundletool*.jar" 2>/dev/null | head -n1)
    if [[ -z "$bundletool_found" || ! -f "$bundletool_found" ]]; then
        echo -e "${RED}NOT FOUND${NC}"
        missing_deps+=("Bundletool ${BUNDLETOOL_VERSION}")
        install_commands+=("download_bundletool")
    else
        echo -e "${GREEN}FOUND ($(basename "$bundletool_found"))${NC}"
    fi
    
    echo ""
    
    # If no missing dependencies, return success
    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        echo -e "${GREEN}[+]${NC} System analysis complete - All dependencies satisfied!"
        echo -e "${GREEN}[+]${NC} Ready for AAB conversion operations."
        echo ""
        return 0
    fi
    
    # Show missing dependencies with better formatting
    echo -e "${RED}=[ DEPENDENCY ISSUES DETECTED ]=${NC}"
    echo ""
    for i in "${!missing_deps[@]}"; do
        echo -e "  ${RED}[-]${NC} ${missing_deps[$i]}"
    done
    echo ""
    
    # Show installation plan
    echo -e "${BLUE}=[ INSTALLATION PLAN ]=${NC}"
    echo ""
    for i in "${!missing_deps[@]}"; do
        local dep="${missing_deps[$i]}"
        local cmd="${install_commands[$i]}"
        if [[ "$cmd" == "download_bundletool" ]]; then
            echo -e "  ${CYAN}[*]${NC} Download Bundletool ${BUNDLETOOL_VERSION} from GitHub"
        else
            echo -e "  ${CYAN}[*]${NC} Install: sudo apt update && sudo apt install -y ..."
        fi
    done
    echo ""
    
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





secure_read() {
    local prompt="$1"
    local var_name="$2"
    
    echo -n "$prompt"
    read -s "$var_name"
    echo ""  # New line after silent input
}

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

# ========== ERROR RECOVERY ========== #
retry_operation() {
    local max_attempts=$1
    local operation_name="$2"
    shift 2
    
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        log_info "$operation_name (attempt $attempt/$max_attempts)"
        
        if "$@"; then
            return 0
        fi
        
        if [ $attempt -lt $max_attempts ]; then
            log_warning "Operation failed, retrying in 3 seconds..."
            sleep 3
        fi
        
        ((attempt++))
    done
    
    log_error "$operation_name failed after $max_attempts attempts"
    return 1
}

safe_operation() {
    local operation_name="$1"
    shift
    
    if "$@"; then
        return 0
    else
        log_error "$operation_name failed"
        return 1
    fi
}

# ========== AAB OPERATIONS ========== #




command_update() {
    echo -e "${GREEN}"
    echo "=[ BUNDLETOOL UPDATE ]="
    echo "+ --- --=[ Check for Updates ]=-- --- +"
    echo -e "${NC}"
    
    check_bundletool_updates
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

command_cleanup() {
    echo -e "${GREEN}"
    echo "=[ CLEANUP MODE ]="
    echo "+ --- --=[ Remove Generated Files ]=-- --- +"
    echo -e "${NC}"
    
    log_info "Scanning for files to clean..."
    
    local files_to_clean=()
    local total_size=0
    
    # Find bundletool files
    while IFS= read -r -d '' file; do
        files_to_clean+=("$file")
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        ((total_size += size))
    done < <(find . -maxdepth 1 -name "bundletool*.jar" -print0 2>/dev/null)
    
    # Find keystore files
    while IFS= read -r -d '' file; do
        files_to_clean+=("$file")
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        ((total_size += size))
    done < <(find . -maxdepth 1 -name "*.keystore" -print0 2>/dev/null)
    
    # Find generated APK files
    while IFS= read -r -d '' file; do
        files_to_clean+=("$file")
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        ((total_size += size))
    done < <(find . -maxdepth 1 -name "*.apks" -print0 2>/dev/null)
    
    if [[ ${#files_to_clean[@]} -eq 0 ]]; then
        log_info "No files found to clean"
        return 0
    fi
    
    echo -e "${YELLOW}[!] Files to be removed:${NC}"
    for file in "${files_to_clean[@]}"; do
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        echo -e "  [-] $(basename "$file") ($(numfmt --to=iec-i --suffix=B $size 2>/dev/null || echo "${size}B"))"
    done
    echo ""
    echo -e "${YELLOW}[!] Total space to be freed: $(numfmt --to=iec-i --suffix=B $total_size 2>/dev/null || echo "${total_size}B")${NC}"
    echo ""
    
    if [[ "$INTERACTIVE" == true ]]; then
        echo -n "[?] Are you sure you want to remove these files? [y/N]: "
        read -r confirm
        case "$confirm" in
            [yY]|[yY][eE][sS])
                ;;
            *)
                log_info "Cleanup cancelled"
                return 0
                ;;
        esac
    fi
    
    local removed=0
    for file in "${files_to_clean[@]}"; do
        if rm -f "$file"; then
            log_success "Removed: $(basename "$file")"
            ((removed++))
        else
            log_error "Failed to remove: $(basename "$file")"
        fi
    done
    
    log_success "Cleanup complete: $removed file(s) removed"
    log_info "Space freed: $(numfmt --to=iec-i --suffix=B $total_size 2>/dev/null || echo "${total_size}B")"
}



# ========== MAIN ========== #
main() {
    set_theme
    load_config
    
    
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
            --secure)
                SECURE_INPUT=true
                shift
                ;;
            --theme)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Theme cannot be empty or start with '-'"
                    exit 1
                fi
                THEME="$2"
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
            convert|validate|info|batch|cleanup|update|examples)
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
    echo -e "${BLUE}[*]${NC} Initializing AAB Converter..."
    sleep 0.5


    # Show header immediately
    show_header
    
    echo -e "${BLUE}[*]${NC} Performing system analysis..."
    sleep 0.3
    
    check_dependencies
    setup_logging
    
    # Save configuration after successful initialization
    save_config
    
    # Show ready message
    echo -e "${GREEN}[+]${NC} AAB Converter initialized successfully!"
    echo -e "${GREEN}[+]${NC} Ready for conversion operations."
    echo ""
    
    # Create output directory if needed
    [[ "$OUTPUT_DIR" != "." ]] && mkdir -p "$OUTPUT_DIR"
    
    # Execute command
    case "$COMMAND" in
        convert)
            echo -e "${BLUE}[*]${NC} Starting conversion process..."
            sleep 0.2
            command_convert "$@"
            ;;
        validate)
            echo -e "${BLUE}[*]${NC} Starting validation process..."
            sleep 0.2
            command_validate "$@"
            ;;
        info)
            echo -e "${BLUE}[*]${NC} Gathering bundle information..."
            sleep 0.2
            command_info "$@"
            ;;
        batch)
            echo -e "${BLUE}[*]${NC} Initializing batch processing mode..."
            sleep 0.2
            command_batch "$@"
            ;;
        cleanup)
            echo -e "${BLUE}[*]${NC} Starting cleanup operations..."
            sleep 0.2
            command_cleanup "$@"
            ;;
        update)
            echo -e "${BLUE}[*]${NC} Checking for updates..."
            sleep 0.2
            command_update "$@"
            ;;
        examples)
            echo -e "${BLUE}[*]${NC} Loading usage examples..."
            sleep 0.2
            command_examples "$@"
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
    
    echo -e "${GREEN}"
    echo "=[ SESSION COMPLETE ]="
    echo "+ --- --=[ Wilson Goal's AAB Converter ]=-- --- +"
    echo -e "${NC}"
    echo -e "${GREEN}[+]${NC} All operations completed successfully!"
}

# Entry point
main "$@"