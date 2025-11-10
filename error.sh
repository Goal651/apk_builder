
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