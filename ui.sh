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
