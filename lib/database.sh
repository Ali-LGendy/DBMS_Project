#!/bin/bash
# database.sh - Database operations

# Create a new database
create_database() {
    show_banner "Create Database"
    
    local database_name=$(get_valid_input "Enter database name" validate_name "database")
    
    if dir_exists "$DB_ROOT_DIR/$database_name"; then
        show_error "Database '$database_name' already exists!"
        log_warning "Attempted to create existing database: $database_name"
        return 1
    fi
    
    mkdir -p "$DB_ROOT_DIR/$database_name"
    show_success "Database '$database_name' created successfully!"
    log_info "Created database: $database_name"
    
    return 0
}

# List all databases
list_databases() {
    show_banner "Available Databases"
    
    if [ ! -d "$DB_ROOT_DIR" ]; then
        show_warning "No DBMS directory found."
        return 1
    fi
    
    local databases=$(find "$DB_ROOT_DIR" -maxdepth 1 -type d -not -path "$DB_ROOT_DIR" -exec basename {} \; | sort)
    
    if [ -z "$databases" ]; then
        show_warning "No databases found."
        return 1
    fi
    
    echo -e "${COLOR_WHITE}Databases:${COLOR_RESET}"
    local count=0
    
    while IFS= read -r db; do
        count=$((count + 1))
        local color=$(get_random_color)
        local db_size=$(du -sh "$DB_ROOT_DIR/$db" | cut -f1)
        local tables=$(find "$DB_ROOT_DIR/$db" -name "*.csv" -not -name "metadata.csv" | wc -l)
        
        echo -e "  ${color}${ICON_DATABASE} $db${COLOR_RESET} (Size: ${COLOR_YELLOW}$db_size${COLOR_RESET}, Tables: ${COLOR_YELLOW}$tables${COLOR_RESET})"
    done <<< "$databases"
    
    echo
    show_info "Total databases: $count"
    
    return 0
}

# Connect to a database
connect_to_database() {
    show_banner "Connect to Database"
    
    list_databases >/dev/null
    
    if [ $? -ne 0 ]; then
        show_error "No databases available to connect."
        return 1
    fi
    
    local databases=$(find "$DB_ROOT_DIR" -maxdepth 1 -type d -not -path "$DB_ROOT_DIR" -exec basename {} \; | sort)
    
    echo -e "${COLOR_WHITE}Available databases:${COLOR_RESET}"
    local db_number=1
    local db_array=()
    
    while IFS= read -r db; do
        local color=$(get_random_color)
        echo -e "  ${COLOR_GREEN}$db_number${COLOR_RESET}) ${color}${ICON_DATABASE} $db${COLOR_RESET}"
        db_array+=("$db")
        db_number=$((db_number + 1))
    done <<< "$databases"
    
    echo
    read -p "$(prompt_text "Enter database number or name to connect")" selection
    
    # Check if selection is a number
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#db_array[@]}" ]; then
        local database_name="${db_array[$((selection-1))]}"
    else
        local database_name="$selection"
    fi
    
    if [ -z "$database_name" ]; then
        show_error "No database name entered."
        return 1
    fi
    
    if ! dir_exists "$DB_ROOT_DIR/$database_name"; then
        show_error "Database '$database_name' does not exist!"
        return 1
    fi
    
    show_success "Connected to '$database_name'."
    log_info "Connected to database: $database_name"
    
    # Enter database operations loop
    handle_database_operations "$database_name"
    
    show_success "Disconnected from '$database_name'."
    log_info "Disconnected from database: $database_name"
    
    return 0
}

# Handle database operations
handle_database_operations() {
    local db_name="$1"
    local db_path="$DB_ROOT_DIR/$db_name"
    
    # Source the table and CRUD operations files
    source "$SCRIPT_DIR/lib/table.sh"
    source "$SCRIPT_DIR/lib/crud.sh"
    
    while true; do
        clear
        show_database_menu "$db_name"
        read -p "$(prompt_text "Select an option")" option
        
        case $option in
            1) # Create Table
                clear
                create_table "$db_path"
                press_any_key
                ;;
            2) # List Tables
                clear
                list_tables "$db_path"
                press_any_key
                ;;
            3) # Drop Table
                clear
                drop_table "$db_path"
                press_any_key
                ;;
            4) # Insert into Table
                clear
                insert_into_table "$db_path"
                press_any_key
                ;;
            5) # Select From Table
                clear
                select_from_table "$db_path"
                press_any_key
                ;;
            6) # Delete From Table
                clear
                delete_from_table "$db_path"
                press_any_key
                ;;
            7) # Update Table
                clear
                update_table "$db_path"
                press_any_key
                ;;
            8) # Back to Main Menu
                return
                ;;
            *)
                show_error "Invalid option, please try again!"
                press_any_key
                ;;
        esac
    done
}

# Drop a database
drop_database() {
    show_banner "Drop Database"
    
    list_databases >/dev/null
    
    if [ $? -ne 0 ]; then
        show_error "No databases available to drop."
        return 1
    fi
    
    local databases=$(find "$DB_ROOT_DIR" -maxdepth 1 -type d -not -path "$DB_ROOT_DIR" -exec basename {} \; | sort)
    
    echo -e "${COLOR_WHITE}Available databases:${COLOR_RESET}"
    local db_number=1
    local db_array=()
    
    while IFS= read -r db; do
        local color=$(get_random_color)
        echo -e "  ${COLOR_GREEN}$db_number${COLOR_RESET}) ${color}${ICON_DATABASE} $db${COLOR_RESET}"
        db_array+=("$db")
        db_number=$((db_number + 1))
    done <<< "$databases"
    
    echo
    read -p "$(prompt_text "Enter database number or name to drop")" selection
    
    # Check if selection is a number
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#db_array[@]}" ]; then
        local database_name="${db_array[$((selection-1))]}"
    else
        local database_name="$selection"
    fi
    
    if [ -z "$database_name" ]; then
        show_error "No database name entered."
        return 1
    fi
    
    if ! dir_exists "$DB_ROOT_DIR/$database_name"; then
        show_error "Database '$database_name' does not exist!"
        return 1
    fi
    
    echo
    read -p "$(prompt_text "Are you sure you want to delete the database '$database_name'? (y/n)")" confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$DB_ROOT_DIR/$database_name"
        show_success "Database '$database_name' deleted successfully."
        log_info "Dropped database: $database_name"
    else
        show_warning "Database deletion canceled."
    fi
    
    return 0
}