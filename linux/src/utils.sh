show_version() {
    echo "Wilson Goal's AAB Converter v${VERSION}"
    echo "Bundletool version: ${BUNDLETOOL_VERSION}"
    echo "Optimized for Ubuntu/Debian Linux distributions"
}

check_dependencies() {
    echo ""
    echo -e "${GREEN}=[ SYSTEM ANALYSIS ]=${NC}"
    echo -e "${GREEN}+ --- --=[ Dependency Check ]=-- --- +${NC}"
    echo ""
    
    local missing_deps=()
    local install_commands=()
    
    # Check Java with spinner
    local java_msg="Analyzing Java Development Kit"
    sleep 0.5 &
    local java_pid=$!
    show_spinner $java_pid "$java_msg"
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
    local curl_msg="Analyzing curl utility"
    sleep 0.3 &
    local curl_pid=$!
    show_spinner $curl_pid "$curl_msg"
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
    local find_msg="Analyzing find utility"
    sleep 0.2 &
    local find_pid=$!
    show_spinner $find_pid "$find_msg"
    wait $find_pid
    
    if command -v find >/dev/null 2>&1; then
        echo -e "${GREEN}FOUND${NC}"
    else
        echo -e "${RED}NOT FOUND${NC}"
        missing_deps+=("findutils")
        install_commands+=("sudo apt update && sudo apt install -y findutils")
    fi
    
    # Check disk utility
    local du_msg="Analyzing disk utility"
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
    local bt_msg="Analyzing Bundletool"
    
    # Filter search paths to avoid find errors on non-existent directories
    local bt_search=()
    for p in "./" "$HOME/" "/usr/local/bin/"; do
        [[ -d "$p" ]] && bt_search+=("$p")
    done
    
    find "${bt_search[@]}" -maxdepth 1 -name "bundletool*.jar" >/dev/null 2>&1 &
    local bundletool_pid=$!
    show_spinner $bundletool_pid "$bt_msg"
    wait $bundletool_pid
    
    local bundletool_found
    bundletool_found=$(find "${bt_search[@]}" -maxdepth 1 -name "bundletool*.jar" 2>/dev/null | head -n1)
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

secure_read() {
    local prompt="$1"
    local var_name="$2"
    
    echo -n "$prompt"
    read -s "$var_name"
    echo ""  # New line after silent input
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
