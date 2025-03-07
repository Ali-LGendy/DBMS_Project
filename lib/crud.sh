#!/bin/bash

insert_into_table() {
    local db_path="$1"
    local metadata_file="$db_path/metadata.csv"

    show_banner "Insert Data"

    if [ ! -f "$metadata_file" ]; then
        show_error "No tables found in this database."
        return 1
    fi

    local table_names=$(grep -v "^table_name" "$metadata_file" | cut -d',' -f1 | sort | uniq)
    if [ -z "$table_names" ]; then
        show_error "No tables found in this database."
        return 1
    fi

    echo -e "${COLOR_WHITE}Available tables:${COLOR_RESET}"
    select table_name in $table_names; do
        if [ -n "$table_name" ]; then
            break
        else
            show_error "Invalid selection."
        fi
    done

    local metadata=$(get_table_metadata "$db_path" "$table_name")
    if [ -z "$metadata" ]; then
        show_error "Failed to retrieve table metadata."
        return 1
    fi

    local columns=$(echo "$metadata" | cut -d'|' -f1)
    local types=$(echo "$metadata" | cut -d'|' -f2)
    local pk_column=$(echo "$metadata" | cut -d'|' -f3)

    local data_file="$db_path/$table_name.csv"
    if [ ! -f "$data_file" ]; then
        touch "$data_file"
        echo "$columns" > "$data_file"
    fi

    local columns_arr=()
    local types_arr=()
    local values=()
    
    IFS=',' read -r -a columns_arr <<< "$columns"
    IFS=',' read -r -a types_arr <<< "$types"
    
    for ((i=0; i<${#columns_arr[@]}; i++)); do
        values[i]=""
    done
    
    echo -e "\n${COLOR_CYAN}Entering data for table '$table_name':${COLOR_RESET}"
    
    for ((i=0; i<${#columns_arr[@]}; i++)); do
        local column="${columns_arr[$i]}"
        local type="${types_arr[$i]}"
        local is_pk=0
        
        if [ "$column" == "$pk_column" ]; then
            is_pk=1
        fi
        
        while true; do
            read -p "$(prompt_text "Enter value for $column ($type)")" input_value
            
            if [ -z "$input_value" ] && [ $is_pk -eq 0 ] && [ "$type" == "string" ]; then
                values[$i]=""
                break
            elif [ -z "$input_value" ] && ([ $is_pk -eq 1 ] || [ "$type" == "int" ]); then
                show_error "Value cannot be empty for $column ($type)"
                continue
            fi
            
            if validate_value "$input_value" "$type" "$column"; then
                if [ $is_pk -eq 1 ]; then
                    if grep -q "^$input_value," "$data_file" || grep -q ",$input_value," "$data_file"; then
                        show_error "Primary key '$input_value' already exists!"
                        continue
                    fi
                fi
                
                values[$i]=$(escape_csv "$input_value")
                break
            fi
        done
    done
    
    local record=""
    for ((i=0; i<${#values[@]}; i++)); do
        record+="${values[$i]},"
    done
    record="${record%,}"
    
    echo "$record" >> "$data_file"
    show_success "Record inserted successfully into table '$table_name'."
    
    return 0
}

select_from_table() {
    local db_path="$1"
    local metadata_file="$db_path/metadata.csv"

    show_banner "Select Data"

    if [ ! -f "$metadata_file" ]; then
        show_error "No tables found in this database."
        return 1
    fi

    local table_names=$(grep -v "^table_name" "$metadata_file" | cut -d',' -f1 | sort | uniq)
    if [ -z "$table_names" ]; then
        show_error "No tables found in this database."
        return 1
    fi

    echo -e "${COLOR_WHITE}Available tables:${COLOR_RESET}"
    select table_name in $table_names; do
        if [ -n "$table_name" ]; then
            break
        else
            show_error "Invalid selection."
        fi
    done

    local metadata=$(get_table_metadata "$db_path" "$table_name")
    local pk_column=$(echo "$metadata" | cut -d'|' -f3)
    local data_file="$db_path/$table_name.csv"

    if [ ! -f "$data_file" ]; then
        show_error "Table '$table_name' has no data."
        return 1
    fi

    echo -e "\n${COLOR_WHITE}Select option:${COLOR_RESET}"
    select opt in "All records" "By primary key"; do
        case $opt in
            "All records")
                echo
                column -t -s ',' < "$data_file" | while read -r line; do
                    echo -e "  ${COLOR_CYAN}$line${COLOR_RESET}"
                done
                break
                ;;
            "By primary key")
                read -p "$(prompt_text "Enter $pk_column value")" pk_value
                result=$(grep -E "(^$pk_value,|,$pk_value,|,$pk_value$)" "$data_file")
                if [ -n "$result" ]; then
                    echo
                    echo -e "  ${COLOR_GREEN}$(echo "$result" | column -t -s ',')${COLOR_RESET}"
                else
                    show_error "No record found with $pk_column = $pk_value"
                fi
                break
                ;;
            *) show_error "Invalid option" ;;
        esac
    done
    
    return 0
}

update_table() {
    local db_path="$1"
    local metadata_file="$db_path/metadata.csv"

    show_banner "Update Data"

    if [ ! -f "$metadata_file" ]; then
        show_error "No tables found in this database."
        return 1
    fi

    local table_names=$(grep -v "^table_name" "$metadata_file" | cut -d',' -f1 | sort | uniq)
    if [ -z "$table_names" ]; then
        show_error "No tables found in this database."
        return 1
    fi

    echo -e "${COLOR_WHITE}Available tables:${COLOR_RESET}"
    select table_name in $table_names; do
        if [ -n "$table_name" ]; then
            break
        else
            show_error "Invalid selection."
        fi
    done

    local metadata=$(get_table_metadata "$db_path" "$table_name")
    local columns_str=$(echo "$metadata" | cut -d'|' -f1)
    local types_str=$(echo "$metadata" | cut -d'|' -f2)
    local pk_column=$(echo "$metadata" | cut -d'|' -f3)

    IFS=',' read -r -a columns <<< "$columns_str"
    IFS=',' read -r -a types <<< "$types_str"

    local data_file="$db_path/$table_name.csv"
    if [ ! -f "$data_file" ]; then
        show_error "Table '$table_name' has no data."
        return 1
    fi

    echo -e "\n${COLOR_CYAN}Current records:${COLOR_RESET}"
    column -t -s ',' < "$data_file"

    read -p "$(prompt_text "Enter $pk_column value to update")" pk_value

    local record_line=$(grep -n -E "(^$pk_value,|,$pk_value,|,$pk_value$)" "$data_file" | cut -d':' -f1)
    if [ -z "$record_line" ]; then
        show_error "No record found with $pk_column = $pk_value"
        return 1
    fi

    local current_record=$(sed -n "${record_line}p" "$data_file")
    echo -e "\n${COLOR_CYAN}Updating record:${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}$(echo "$current_record" | column -t -s ',')${COLOR_RESET}"

    local new_record=""
    local pk_index=0

    for i in "${!columns[@]}"; do
        if [ "${columns[$i]}" == "$pk_column" ]; then
            pk_index=$i
            break
        fi
    done

    IFS=',' read -r -a current_values <<< "$current_record"
    for i in "${!columns[@]}"; do
        local column="${columns[$i]}"
        local type="${types[$i]}"
        local current_value="${current_values[$i]}"
        
        if [ "$i" -eq "$pk_index" ]; then
            new_record+="$current_value,"
            continue
        fi
        
        read -p "$(prompt_text "Update $column ($type) [current: $current_value]")" new_value
        
        if [ -z "$new_value" ]; then
            new_record+="$current_value,"
        else
            if validate_value "$new_value" "$type" "$column"; then
                new_record+="$(escape_csv "$new_value"),"
            else
                new_record+="$current_value,"
            fi
        fi
    done

    new_record="${new_record%,}"

    sed -i "${record_line}s/.*/$new_record/" "$data_file"
    
    echo -e "\n${COLOR_GREEN}Record updated successfully!${COLOR_RESET}"
    return 0
}

delete_from_table() {
    local db_path="$1"
    local metadata_file="$db_path/metadata.csv"

    show_banner "Delete Data"

    if [ ! -f "$metadata_file" ]; then
        show_error "No tables found in this database."
        return 1
    fi

    local table_names=$(grep -v "^table_name" "$metadata_file" | cut -d',' -f1 | sort | uniq)
    if [ -z "$table_names" ]; then
        show_error "No tables found in this database."
        return 1
    fi

    echo -e "${COLOR_WHITE}Available tables:${COLOR_RESET}"
    select table_name in $table_names; do
        if [ -n "$table_name" ]; then
            break
        else
            show_error "Invalid selection."
        fi
    done

    local metadata=$(get_table_metadata "$db_path" "$table_name")
    local pk_column=$(echo "$metadata" | cut -d'|' -f3)
    local data_file="$db_path/$table_name.csv"

    if [ ! -f "$data_file" ]; then
        show_error "Table '$table_name' has no data."
        return 1
    fi

    echo -e "\n${COLOR_CYAN}Current records:${COLOR_RESET}"
    column -t -s ',' < "$data_file"

    local header=$(head -n 1 "$data_file")
    IFS=',' read -r -a header_arr <<< "$header"
    
    local pk_index=-1
    for i in "${!header_arr[@]}"; do
        if [ "${header_arr[$i]}" = "$pk_column" ]; then
            pk_index=$i
            break
        fi
    done
    
    if [ $pk_index -eq -1 ]; then
        pk_index=0
        pk_column="${header_arr[0]}"
    fi
    
    read -p "$(prompt_text "Enter $pk_column value to delete")" pk_value
    
    local temp_file=$(mktemp)
    local deleted=0
    
    echo "$header" > "$temp_file"
    
    {
        read header_line
        
        while IFS= read -r line || [ -n "$line" ]; do
            IFS=',' read -r -a values <<< "$line"
            
            if [ ${#values[@]} -eq 0 ]; then
                continue
            fi
            
            if [ ${#values[@]} -gt $pk_index ]; then
                pk_value_trimmed=$(echo "$pk_value" | tr -d '[:space:]')
                value_trimmed=$(echo "${values[$pk_index]}" | tr -d '[:space:]')
                
                if [ "$value_trimmed" = "$pk_value_trimmed" ]; then
                    deleted=1
                else
                    echo "$line" >> "$temp_file"
                fi
            else
                echo "$line" >> "$temp_file"
            fi
        done
    } < "$data_file"
    
    if [ $deleted -eq 1 ]; then
        mv "$temp_file" "$data_file"
        show_success "Record deleted successfully from table '$table_name'."
        echo -e "\n${COLOR_CYAN}Updated records:${COLOR_RESET}"
        column -t -s ',' < "$data_file"
    else
        rm "$temp_file"
        show_error "No record found with $pk_column = $pk_value"
    fi
    
    return 0
}
