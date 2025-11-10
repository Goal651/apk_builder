
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
