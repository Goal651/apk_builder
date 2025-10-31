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
SECURE_INPUT=false
THEME="msf"

# ========== COLOR THEMES ========== #
set_theme() {
    case "$THEME" in
        "msf")
            # Default MSF colors
            readonly RED='\033[0;31m'
            readonly GREEN='\033[0;32m'
            readonly YELLOW='\033[1;33m'
            readonly BLUE='\033[0;34m'
            readonly MAGENTA='\033[0;35m'
            readonly CYAN='\033[0;36m'
            ;;
        "dark")
            # Dark theme
            readonly RED='\033[0;31m'
            readonly GREEN='\033[0;32m'
            readonly YELLOW='\033[0;33m'
            readonly BLUE='\033[0;34m'
            readonly MAGENTA='\033[0;35m'
            readonly CYAN='\033[0;36m'
            ;;
        "light")
            # Light theme
            readonly RED='\033[1;31m'
            readonly GREEN='\033[1;32m'
            readonly YELLOW='\033[1;33m'
            readonly BLUE='\033[1;34m'
            readonly MAGENTA='\033[1;35m'
            readonly CYAN='\033[1;36m'
            ;;
        "minimal")
            # Minimal colors
            readonly RED='\033[31m'
            readonly GREEN='\033[32m'
            readonly YELLOW='\033[33m'
            readonly BLUE='\033[34m'
            readonly MAGENTA='\033[35m'
            readonly CYAN='\033[36m'
            ;;
        *)
            log_warning "Unknown theme '$THEME', using default MSF theme"
            THEME="msf"
            set_theme
            ;;
    esac
    
    readonly BOLD='\033[1m'
    readonly NC='\033[0m' # No Color
}

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
show_header() {
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                              ║"
    echo "║                    █████╗  █████╗ ██████╗     ████████╗ ██████╗              ║"
    echo "║                   ██╔══██╗██╔══██╗██╔══██╗    ╚══██╔══╝██╔═══██╗             ║"
    echo "║                   ███████║███████║██████╔╝       ██║   ██║   ██║             ║"
    echo "║                   ██╔══██║██╔══██║██╔══██╗       ██║   ██║   ██║             ║"
    echo "║                   ██║  ██║██║  ██║██████╔╝       ██║   ╚██████╔╝             ║"
    echo "║                   ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝        ╚═╝    ╚═════╝              ║"
    echo "║                                                                              ║"
    echo "║                 ██████╗ ██████╗ ███╗   ██╗██╗   ██╗███████╗██████╗ ████████╗ ║"
    echo "║                ██╔════╝██╔═══██╗████╗  ██║██║   ██║██╔════╝██╔══██╗╚══██╔══╝ ║"
    echo "║                ██║     ██║   ██║██╔██╗ ██║██║   ██║█████╗  ██████╔╝   ██║    ║"
    echo "║                ██║     ██║   ██║██║╚██╗██║╚██╗ ██╔╝██╔══╝  ██╔══██╗   ██║    ║"
    echo "║                ╚██████╗╚██████╔╝██║ ╚████║ ╚████╔╝ ███████╗██║  ██║   ██║    ║"
    echo "║                 ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝    ║"
    echo "║                                                                              ║"
    echo "║                          LINUX CLI EDITION v${VERSION}                           ║"
    echo "║                                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}                 =[ Wilson Goal's AAB to APKS Converter ]=${NC}"
    echo -e "${GREEN}                 + --- --=[ Ubuntu/Debian Optimized ]=-- --- +${NC}"
    echo -e "${GREEN}                 + --- --=[ Auto-deps • Interactive ]=-- --- +${NC}"
    echo -e "${GREEN}                 + --- --=[ Feature-rich • User-friendly ]=-- --- +${NC}"
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

command_examples() {
    echo -e "${GREEN}"
    echo "=[ USAGE EXAMPLES ]="
    echo "+ --- --=[ Practical Usage Guide ]=-- --- +"
    echo -e "${NC}"
    
    echo -e "${CYAN}BASIC USAGE:${NC}"
    echo -e "  ${GREEN}./builder.sh${NC}                          # Interactive conversion"
    echo -e "  ${GREEN}./builder.sh --non-interactive${NC}       # Batch conversion"
    echo -e "  ${GREEN}./builder.sh validate${NC}                 # Validate bundles"
    echo ""
    
    echo -e "${CYAN}CUSTOM CONFIGURATION:${NC}"
    echo -e "  ${GREEN}./builder.sh -o ./output${NC}              # Custom output directory"
    echo -e "  ${GREEN}./builder.sh -k mykey.keystore${NC}       # Custom keystore"
    echo -e "  ${GREEN}./builder.sh -a myalias${NC}               # Custom alias"
    echo ""
    
    echo -e "${CYAN}ADVANCED OPTIONS:${NC}"
    echo -e "  ${GREEN}./builder.sh --secure${NC}                 # Hidden password input"
    echo -e "  ${GREEN}./builder.sh -l conversion.log${NC}       # Log to file"
    echo -e "  ${GREEN}./builder.sh -m system${NC}               # System APKs only"
    echo ""
    
    echo -e "${CYAN}MAINTENANCE:${NC}"
    echo -e "  ${GREEN}./builder.sh batch${NC}                   # Batch processing mode"
    echo -e "  ${GREEN}./builder.sh cleanup${NC}                 # Remove generated files"
    echo -e "  ${GREEN}./builder.sh examples${NC}                # Show this help"
    echo ""
    
    echo -e "${CYAN}WORKFLOW EXAMPLES:${NC}"
    echo -e "  # Convert all AAB files in current directory"
    echo -e "  ${GREEN}./builder.sh --non-interactive${NC}"
    echo ""
    echo -e "  # Convert with custom settings and logging"
    echo -e "  ${GREEN}./builder.sh -o ./apks -k release.keystore -l build.log${NC}"
    echo ""
    echo -e "  # Batch process with progress tracking"
    echo -e "  ${GREEN}./builder.sh batch${NC}"
    echo ""
    echo -e "  # Clean up after conversion"
    echo -e "  ${GREEN}./builder.sh cleanup${NC}"
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