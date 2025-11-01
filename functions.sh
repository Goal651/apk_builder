#!/usr/bin/env bash

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
secure_read() {
    local prompt="$1"
    local var_name="$2"
    
    echo -n "$prompt"
    read -s "$var_name"
    echo ""  # New line after silent input
}

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
