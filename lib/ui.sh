#!/bin/bash
# ui.sh - User interface components and styling

# Draw a horizontal line
draw_line() {
    local width=${1:-$UI_WIDTH}
    local char=${2:-$UI_BORDER_CHAR}
    printf "%${width}s\n" | tr " " "$char"
}

# Create a centered text with padding
center_text() {
    local text="$1"
    local width=${2:-$UI_WIDTH}
    local padding=$(( (width - ${#text}) / 2 ))
    
    printf "%${padding}s%s%${padding}s\n" "" "$text" ""
}

# Show a styled banner
show_banner() {
    local title="$1"
    local color=${2:-$COLOR_CYAN}
    
    echo -e "$color"
    draw_line
    echo
    center_text "$title"
    echo
    draw_line
    echo -e "$COLOR_RESET"
}

# Welcome banner
show_welcome_banner() {
    clear
    echo -e "$COLOR_CYAN"
    draw_line
    echo
    center_text "Welcome to $DB_NAME $DB_VERSION"
    center_text "Bash Database Management System"
    center_text "Developed by Anas Nashat & Ali El-Gendy"
    center_text "© $(date +%Y) - All Rights Reserved"
    echo
    draw_line
    echo -e "$COLOR_RESET"
    echo
}

# Exit banner
show_exit_banner() {
    echo -e "$COLOR_CYAN"
    draw_line
    echo
    center_text "Thank you for using $DB_NAME"
    center_text "Developed by Anas Nashat & Ali El-Gendy"
    center_text "© $(date +%Y) - All Rights Reserved"
    center_text "Goodbye!"
    echo
    draw_line
    echo -e "$COLOR_RESET"
    echo
}

# Display main menu
show_main_menu() {
    echo -e "$COLOR_CYAN"
    draw_line
    center_text "MAIN MENU"
    draw_line
    echo -e "$COLOR_RESET"
    
    echo -e "  ${COLOR_GREEN}1${COLOR_RESET}) ${ICON_DATABASE} ${COLOR_WHITE}Create Database${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}2${COLOR_RESET}) ${ICON_DATABASE} ${COLOR_WHITE}List Databases${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}3${COLOR_RESET}) ${ICON_CONNECT} ${COLOR_WHITE}Connect to Database${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}4${COLOR_RESET}) ${ICON_DATABASE} ${COLOR_WHITE}Drop Database${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}5${COLOR_RESET}) ${COLOR_WHITE}Exit${COLOR_RESET}"
    
    echo -e "$COLOR_CYAN"
    draw_line
    echo -e "$COLOR_RESET"
    echo
}

# Display database operations menu
show_database_menu() {
    local db_name="$1"
    
    echo -e "$COLOR_CYAN"
    draw_line
    center_text "DATABASE: $db_name"
    draw_line
    echo -e "$COLOR_RESET"
    
    echo -e "  ${COLOR_GREEN}1${COLOR_RESET}) ${ICON_TABLE} ${COLOR_WHITE}Create Table${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}2${COLOR_RESET}) ${ICON_TABLE} ${COLOR_WHITE}List Tables${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}3${COLOR_RESET}) ${ICON_TABLE} ${COLOR_WHITE}Drop Table${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}4${COLOR_RESET}) ${ICON_TABLE} ${COLOR_WHITE}Insert into Table${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}5${COLOR_RESET}) ${ICON_TABLE} ${COLOR_WHITE}Select From Table${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}6${COLOR_RESET}) ${ICON_TABLE} ${COLOR_WHITE}Delete From Table${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}7${COLOR_RESET}) ${ICON_TABLE} ${COLOR_WHITE}Update Table${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}8${COLOR_RESET}) ${COLOR_WHITE}Back to Main Menu${COLOR_RESET}"
    
    echo -e "$COLOR_CYAN"
    draw_line
    echo -e "$COLOR_RESET"
    echo
}

# Show success message
show_success() {
    echo -e "${COLOR_GREEN}${ICON_SUCCESS} $1${COLOR_RESET}"
}

# Show error message
show_error() {
    echo -e "${COLOR_RED}${ICON_ERROR} $1${COLOR_RESET}"
}

# Show warning message
show_warning() {
    echo -e "${COLOR_YELLOW}${ICON_WARNING} $1${COLOR_RESET}"
}

# Show info message
show_info() {
    echo -e "${COLOR_BLUE}${ICON_INFO} $1${COLOR_RESET}"
}

# Create a styled prompt text
prompt_text() {
    echo -e "${COLOR_CYAN}$1${COLOR_RESET}: "
}

# Wait for any key press
press_any_key() {
    echo
    read -n 1 -s -r -p "$(echo -e "${COLOR_YELLOW}Press any key to continue...${COLOR_RESET}")"
    echo
}

# Display data in a table format
display_table() {
    local header="$1"
    local data="$2"
    local title="${3:-Data}"
    
    echo -e "${COLOR_CYAN}$title:${COLOR_RESET}"
    echo -e "${COLOR_WHITE}$header${COLOR_RESET}"
    draw_line $(echo "$header" | wc -c) "-"
    echo -e "$data"
    echo
}