
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