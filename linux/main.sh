#!/usr/bin/env bash
# AAB to APKS Converter Tool - Linux CLI Edition
# Created by Wilson Goal
# Version 2.0 - 2025
# Optimized for Ubuntu/Debian-based Linux distributions

set -o errexit  # Exit on error
set -o nounset  # Exit on unset variables
set -o pipefail # Catch pipe fails
shopt -s nullglob # Ensure globs expand to empty array when no matches

source './src/aab.sh'
source './src/bundle_tool.sh'
source './src/config.sh'
source './src/constant.sh'
source './src/error.sh'
source './src/help.sh'
source './src/keystore.sh'
source './src/logger.sh'
source './src/theme.sh'
source './src/ui.sh'
source './src/utils.sh'



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
    sleep 1

    
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