
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