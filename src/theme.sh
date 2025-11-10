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
