#!/bin/bash
# settings.sh - Configuration settings for the DBMS

# Database settings
DB_ROOT_DIR="$HOME/DBMS"
DB_LOG_FILE="$DB_ROOT_DIR/dbms.log"
DB_VERSION="1.0.0"
DB_NAME="BashDB"

# UI settings
UI_BORDER_CHAR="═"
UI_WIDTH=60

# Color definitions
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_MAGENTA='\033[0;35m'
COLOR_CYAN='\033[0;36m'
COLOR_WHITE='\033[1;37m'
COLOR_RESET='\033[0m'

# Icons for UI
ICON_SUCCESS="✓"
ICON_ERROR="✗"
ICON_WARNING="⚠"
ICON_INFO="ℹ"
ICON_DATABASE="📁"
ICON_TABLE="📋"
ICON_CONNECT="🔌"