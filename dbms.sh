#!/bin/bash
# dbms.sh - Main entry point for the DBMS system

# Set script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required files
source "$SCRIPT_DIR/config/settings.sh"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/database.sh"
source "$SCRIPT_DIR/lib/utils.sh"

# Check if the DBMS directory exists, create if not
if [ ! -d "$DB_ROOT_DIR" ]; then
    mkdir -p "$DB_ROOT_DIR"
    log_info "Created root directory: $DB_ROOT_DIR"
fi

# Display welcome message
clear
show_welcome_banner

# Main program loop
while true; do
    show_main_menu
    read -p "$(prompt_text "Select an option")" option
    
    case $option in
        1) # Create Database
            clear
            create_database
            press_any_key
            ;;
        2) # List Databases
            clear
            list_databases
            press_any_key
            ;;
        3) # Connect to Database
            clear
            connect_to_database
            ;;
        4) # Drop Database
            clear
            drop_database
            press_any_key
            ;;
        5) # Exit
            clear
            show_exit_banner
            exit 0
            ;;
        *)
            show_error "Invalid option, please try again!"
            press_any_key
            ;;
    esac
    
    clear
done