#!/bin/bash
# table.sh - Table operations

# Create a new table
create_table() {
    local db_path="$1"
    local metadata_file="$db_path/metadata.csv"

    show_banner "Create Table"

    if [ ! -f "$metadata_file" ]; then
        echo "table_name,column_name,data_type,is_primary_key" > "$metadata_file"
        log_info "Created metadata file for database: $(basename "$db_path")"
    fi

    while true; do
        local table_name=$(get_valid_input "Enter table name" validate_name "table")

        if grep -q "^$table_name," "$metadata_file"; then
            show_error "Table '$table_name' already exists!"
            read -p "$(prompt_text "Try another name? (y/n)")" try_again
            if [[ ! "$try_again" =~ ^[Yy]$ ]]; then
                return 1
            fi
            continue
        fi

        show_success "Creating table: $table_name"

        local columns_num=0
        while true; do
            read -p "$(prompt_text "Enter number of columns")" columns_num

            if ! [[ $columns_num =~ ^[0-9]+$ ]]; then
                show_error "Input is not a number."
            elif [ $columns_num -le 0 ]; then
                show_error "Value must be greater than zero."
            else
                break
            fi
        done

        local primary_key_set=0
        local column_defs=""

        echo -e "\n${COLOR_CYAN}Defining columns for table '$table_name':${COLOR_RESET}"

        for ((i=1; i<=columns_num; i++)); do
            echo -e "\n${COLOR_WHITE}Column $i:${COLOR_RESET}"

            local column_name=$(get_valid_input "Enter column name" validate_name "column")

            local column_type=""
            while true; do
                read -p "$(prompt_text "Enter column type (int/string)")" column_type

                if [ -z "$column_type" ]; then
                    show_error "Column type cannot be empty."
                elif [[ "$column_type" != "int" && "$column_type" != "string" ]]; then
                    show_error "Invalid column type! Only 'int' or 'string' allowed."
                else
                    break
                fi
            done

            local is_primary_key=0

            if [ $primary_key_set -eq 0 ]; then
                if [ $i -eq 1 ]; then
                    is_primary_key=1
                    primary_key_set=1
                    show_info "Column '$column_name' set as PRIMARY KEY"
                else
                    read -p "$(prompt_text "Make this column a PRIMARY KEY? (y/n)")" make_pk
                    if [[ "$make_pk" =~ ^[Yy]$ ]]; then
                        is_primary_key=1
                        primary_key_set=1
                        show_info "Column '$column_name' set as PRIMARY KEY"
                    fi
                fi
            fi

            echo "$table_name,$column_name,$column_type,$is_primary_key" >> "$metadata_file"

            if [ -n "$column_defs" ]; then
                column_defs="$column_defs, "
            fi
            column_defs="${column_defs}${column_name} (${column_type})"
            if [ $is_primary_key -eq 1 ]; then
                column_defs="${column_defs} PRIMARY KEY"
            fi
        done

        touch "$db_path/$table_name.csv"

        show_success "Table '$table_name' created successfully!"
        show_info "Schema: $column_defs"
        log_info "Created table: $table_name in database: $(basename "$db_path")"

        read -p "$(prompt_text "Create another table? (y/n)")" create_another
        if [[ ! "$create_another" =~ ^[Yy]$ ]]; then
            break
        fi
    done

    return 0
}

# List all tables in the database
list_tables() {
    local db_path="$1"
    local metadata_file="$db_path/metadata.csv"

    show_banner "Tables in $(basename "$db_path")"

    if [ ! -f "$metadata_file" ]; then
        show_warning "No tables found in this database."
        return 1
    fi

    local table_names=$(grep -v "^table_name" "$metadata_file" | cut -d',' -f1 | sort | uniq)

    if [ -z "$table_names" ]; then
        show_warning "No tables found in this database."
        return 1
    fi

    echo -e "${COLOR_WHITE}Tables:${COLOR_RESET}"
    local count=0

    while IFS= read -r table; do
        count=$((count + 1))
        local color=$(get_random_color)
        local rows=$([ -f "$db_path/$table.csv" ] && wc -l < "$db_path/$table.csv" || echo "0")
        local columns=$(grep "^$table," "$metadata_file" | wc -l)

        echo -e "  ${color}${ICON_TABLE} $table${COLOR_RESET} (Columns: ${COLOR_YELLOW}$columns${COLOR_RESET}, Rows: ${COLOR_YELLOW}$rows${COLOR_RESET})"

        # Display column information
        echo -e "    ${COLOR_WHITE}Columns:${COLOR_RESET}"
        grep "^$table," "$metadata_file" | while IFS=',' read -r _ col_name data_type is_pk; do
            local pk_text=""
            if [ "$is_pk" -eq 1 ]; then
                pk_text=" ${COLOR_YELLOW}(PRIMARY KEY)${COLOR_RESET}"
            fi
            echo -e "      - ${COLOR_CYAN}$col_name${COLOR_RESET} (${COLOR_GREEN}$data_type${COLOR_RESET})$pk_text"
        done
        echo
    done <<< "$table_names"

    show_info "Total tables: $count"

    return 0
}

# Drop a table
drop_table() {
    local db_path="$1"
    local metadata_file="$db_path/metadata.csv"

    show_banner "Drop Table"

    if [ ! -f "$metadata_file" ]; then
        show_warning "No tables found in this database."
        return 1
    fi

    local table_names=$(grep -v "^table_name" "$metadata_file" | cut -d',' -f1 | sort | uniq)

    if [ -z "$table_names" ]; then
        show_warning "No tables found in this database."
        return 1
    fi

    echo -e "${COLOR_WHITE}Available tables:${COLOR_RESET}"
    local table_number=1
    local table_array=()

    while IFS= read -r table; do
        local color=$(get_random_color)
        echo -e "  ${COLOR_GREEN}$table_number${COLOR_RESET}) ${color}${ICON_TABLE} $table${COLOR_RESET}"
        table_array+=("$table")
        table_number=$((table_number + 1))
    done <<< "$table_names"

    echo
    read -p "$(prompt_text "Enter table number or name to drop")" selection

    # Check if selection is a number
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#table_array[@]}" ]; then
        local table_name="${table_array[$((selection-1))]}"
    else
        local table_name="$selection"
    fi

    if [ -z "$table_name" ]; then
        show_error "No table name entered."
        return 1
    fi

    if ! grep -q "^$table_name," "$metadata_file"; then
        show_error "Table '$table_name' does not exist!"
        return 1
    fi

    echo
    read -p "$(prompt_text "Are you sure you want to drop table '$table_name'? (y/n)")" confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Remove table data file
        rm -f "$db_path/$table_name.csv"

        # Remove table entries from metadata
        sed -i "/^$table_name,/d" "$metadata_file"

        show_success "Table '$table_name' dropped successfully."
        log_info "Dropped table: $table_name from database: $(basename "$db_path")"
    else
        show_warning "Table drop canceled."
    fi

    return 0
}

# Get table metadata
get_table_metadata() {
    local db_path="$1"
    local table_name="$2"
    local metadata_file="$db_path/metadata.csv"

    if [ ! -f "$metadata_file" ]; then
        echo ""
        return 1
    fi

    if ! grep -q "^$table_name," "$metadata_file"; then
        echo ""
        return 1
    fi

    local columns=$(grep "^$table_name," "$metadata_file" | cut -d',' -f2 | tr '\n' ',' | sed 's/,$//')
    local types=$(grep "^$table_name," "$metadata_file" | cut -d',' -f3 | tr '\n' ',' | sed 's/,$//')
    local pk_column=$(grep "^$table_name," "$metadata_file" | awk -F',' '$4 == 1 {print $2}' | head -n 1)

    echo "${columns}|${types}|${pk_column}"
    return 0
}

# Check if a table exists
table_exists() {
    local db_path="$1"
    local table_name="$2"
    local metadata_file="$db_path/metadata.csv"

    if [ ! -f "$metadata_file" ]; then
        return 1
    fi

    if grep -q "^$table_name," "$metadata_file"; then
        return 0
    else
        return 1
    fi
}
