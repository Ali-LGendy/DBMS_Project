#!/bin/bash
# utils.sh - Utility functions for the DBMS

# Validate that a name starts with a letter and contains only valid characters
validate_name() {
    local name="$1"
    local type="${2:-name}"
    
    if [ -z "$name" ]; then
        show_error "$type name cannot be empty"
        return 1
    fi
    
    if [[ ! "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        show_error "Invalid $type name: Must start with a letter and contain only letters, numbers, or underscores"
        return 1
    fi
    
    return 0
}

# Validate a value against a specified data type
validate_value() {
    local value="$1"
    local type="$2"
    local column="$3"
    
    case "$type" in
        "int")
            if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
                show_error "Invalid input: '$value' is not an integer for column '$column'"
                return 1
            fi
            ;;
        "string")
            if [ -z "$value" ]; then
                show_error "Invalid input: String value cannot be empty for column '$column'"
                return 1
            fi
            ;;
        *)
            show_error "Unknown data type: $type"
            return 1
            ;;
    esac
    
    return 0
}

# Get a valid input from the user
get_valid_input() {
    local prompt="$1"
    local validation_func="$2"
    local arg1="$3"
    local arg2="$4"
    
    while true; do
        read -p "$(prompt_text "$prompt")" input
        
        if $validation_func "$input" "$arg1" "$arg2"; then
            echo "$input"
            return 0
        fi
    done
}

# Log messages to the log file
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Create log directory if it doesn't exist
    local log_dir=$(dirname "$DB_LOG_FILE")
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir"
    fi
    
    # Append to log file
    echo "[$timestamp] [$level] $message" >> "$DB_LOG_FILE"
}

# Log levels
log_info() {
    log_message "INFO" "$1"
}

log_warning() {
    log_message "WARNING" "$1"
}

log_error() {
    log_message "ERROR" "$1"
}

# Check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Check if a directory exists
dir_exists() {
    [ -d "$1" ]
}

# Get a random color
get_random_color() {
    local colors=("$COLOR_RED" "$COLOR_GREEN" "$COLOR_YELLOW" "$COLOR_BLUE" "$COLOR_MAGENTA" "$COLOR_CYAN")
    local random_index=$(( RANDOM % ${#colors[@]} ))
    echo "${colors[$random_index]}"
}

# Escape special characters in CSV
escape_csv() {
    local input="$1"
    echo "$input" | sed 's/,/\\,/g'
}

# Unescape special characters in CSV
unescape_csv() {
    local input="$1"
    echo "$input" | sed 's/\\,/,/g'
}