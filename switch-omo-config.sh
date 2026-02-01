#!/bin/bash
# Switch oh-my-opencode configuration profiles
# Usage: ./switch-omo-config.sh

# Check if gum is installed, prompt to install if not
check_gum() {
    if ! command -v gum >/dev/null 2>&1; then
        echo "This script requires 'gum' for the modern UI."
        echo "Install with: brew install gum"
        echo ""
        read -r -p "Continue with basic interface instead? [Y/n] " use_basic
        if [[ "$use_basic" =~ ^[Nn]$ ]]; then
            echo "Please install gum first: brew install gum"
            exit 1
        fi
        return 1
    fi
    return 0
}

# Setup Gum theme - One Dark Pro (VS Code inspired)
setup_gum_theme() {
    # One Dark Pro color palette
    local bg="#282c34"           # Background
    local fg="#abb2bf"           # Foreground text
    local blue="#61afef"         # Primary accent (blue)
    local green="#98c379"        # Success (green)
    local red="#e06c75"          # Error (red)
    local yellow="#e5c07b"       # Warning (yellow)
    local purple="#c678dd"       # Secondary accent (purple)
    local cyan="#56b6c2"         # Tertiary accent (cyan)

    # Style settings
    export GUM_STYLE_BORDER="rounded"
    export GUM_STYLE_BORDER_FOREGROUND="$blue"
    export GUM_STYLE_FOREGROUND="$fg"
    export GUM_STYLE_BACKGROUND="$bg"
    export GUM_STYLE_MARGIN="1 0"
    export GUM_STYLE_PADDING="2 4"

    # Choose settings
    export GUM_CHOOSE_CURSOR_FOREGROUND="$blue"
    export GUM_CHOOSE_ITEM_FOREGROUND="$fg"
    export GUM_CHOOSE_SELECTED_FOREGROUND="$green"
    export GUM_CHOOSE_HEADER_FOREGROUND="$cyan"
    export GUM_CHOOSE_CURSOR="→ "
    export GUM_CHOOSE_SELECTED_PREFIX="✓ "
    export GUM_CHOOSE_UNSELECTED_PREFIX="  "
    export GUM_CHOOSE_HEIGHT=15

    # Confirm settings
    export GUM_CONFIRM_PROMPT_FOREGROUND="$fg"
    export GUM_CONFIRM_SELECTED_FOREGROUND="$bg"
    export GUM_CONFIRM_SELECTED_BACKGROUND="$green"
    export GUM_CONFIRM_UNSELECTED_FOREGROUND="$fg"
    export GUM_CONFIRM_UNSELECTED_BACKGROUND="#3e4451"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CENTRAL_CONFIG_DIR="$HOME/.config/opencode"
PROJECT_ROOT_DIR="$PWD"
PROJECT_CONFIG_DIR="$PROJECT_ROOT_DIR/.opencode"

CONFIG_DIR="$CENTRAL_CONFIG_DIR"
TARGET_FILE="$CONFIG_DIR/oh-my-opencode.json"

use_project_config_dir="false"

if [[ -d "$PROJECT_CONFIG_DIR" ]]; then
    use_project_config_dir="true"
else
    PROJECT_CREATE_CHOICE_FILE="$PROJECT_ROOT_DIR/.switch-omo-config.create-opencode"

    create_opencode=""
    if [[ -f "$PROJECT_CREATE_CHOICE_FILE" ]]; then
        create_opencode=$(tr -d ' \t\r\n' < "$PROJECT_CREATE_CHOICE_FILE")
    fi

    if [[ ! "$create_opencode" =~ ^[YyNn]$ ]]; then
        if command -v gum >/dev/null 2>&1; then
            setup_gum_theme
            gum style --margin "1 0" --padding "1 2" \
                "No .opencode directory detected in: $PROJECT_ROOT_DIR"
            if gum confirm "Create .opencode directory here for project-local switching?" \
                --default=false --affirmative "Yes" --negative "No"; then
                create_opencode="y"
                printf '%s\n' "y" > "$PROJECT_CREATE_CHOICE_FILE"
            else
                create_opencode="n"
                printf '%s\n' "n" > "$PROJECT_CREATE_CHOICE_FILE"
            fi
        else
            echo "No .opencode directory detected in current directory: $PROJECT_ROOT_DIR"
            read -r -p "Create .opencode directory here for project-local switching? [y/N] " create_opencode
            if [[ "$create_opencode" =~ ^[Yy]$ ]]; then
                printf '%s\n' "y" > "$PROJECT_CREATE_CHOICE_FILE"
            else
                printf '%s\n' "n" > "$PROJECT_CREATE_CHOICE_FILE"
            fi
        fi
    fi

    if [[ "$create_opencode" =~ ^[Yy]$ ]]; then
        if mkdir -p "$PROJECT_CONFIG_DIR" && [[ -d "$PROJECT_CONFIG_DIR" ]]; then
            use_project_config_dir="true"
        else
            echo "Error: Failed to create $PROJECT_CONFIG_DIR (check permissions)"
            use_project_config_dir="false"
        fi
    fi
fi

if [[ "$use_project_config_dir" == "true" ]]; then
    CONFIG_DIR="$PROJECT_CONFIG_DIR"
    TARGET_FILE="$CONFIG_DIR/oh-my-opencode.json"

    PROJECT_COPY_CHOICE_FILE="$PROJECT_CONFIG_DIR/.switch-omo-config.copy-profiles"

    if compgen -G "$CENTRAL_CONFIG_DIR/oh-my-opencode-*.json" > /dev/null; then
        copy_profiles=""
        if [[ -f "$PROJECT_COPY_CHOICE_FILE" ]]; then
            copy_profiles=$(tr -d ' \t\r\n' < "$PROJECT_COPY_CHOICE_FILE")
        fi

        if [[ ! "$copy_profiles" =~ ^[YyNn]$ ]]; then
            if command -v gum >/dev/null 2>&1; then
                setup_gum_theme
                gum style --margin "1 0" --padding "1 2" \
                    "Detected .opencode in: $PROJECT_CONFIG_DIR"
                if gum confirm "Copy central oh-my-opencode-*.json profiles into project directory?" \
                    --default=false --affirmative "Yes" --negative "No"; then
                    copy_profiles="y"
                    printf '%s\n' "y" > "$PROJECT_COPY_CHOICE_FILE"
                else
                    copy_profiles="n"
                    printf '%s\n' "n" > "$PROJECT_COPY_CHOICE_FILE"
                fi
            else
                echo "Detected .opencode in current directory: $PROJECT_CONFIG_DIR"
                read -r -p "Copy central oh-my-opencode-*.json profiles into $PROJECT_CONFIG_DIR? [y/N] " copy_profiles
                if [[ "$copy_profiles" =~ ^[Yy]$ ]]; then
                    printf '%s\n' "y" > "$PROJECT_COPY_CHOICE_FILE"
                else
                    printf '%s\n' "n" > "$PROJECT_COPY_CHOICE_FILE"
                fi
            fi
        fi

        if [[ "$copy_profiles" =~ ^[Yy]$ ]]; then
            for src in "$CENTRAL_CONFIG_DIR"/oh-my-opencode-*.json; do
                dest="$PROJECT_CONFIG_DIR/$(basename "$src")"
                if [[ -e "$dest" ]]; then
                    continue
                fi
                cp "$src" "$dest"
            done
        fi
    fi
fi

# Colors
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Check gum and setup theme early if available
if command -v gum >/dev/null 2>&1; then
    setup_gum_theme
fi

# Get list of config files (excluding the main one)
get_configs() {
    {
        find "$CONFIG_DIR" -maxdepth 1 -name "oh-my-opencode-*.json" -type f 2>/dev/null
        find "$SCRIPT_DIR" -maxdepth 1 -name "oh-my-opencode-*.json" -type f 2>/dev/null
    } | sort -u
}

# Extract display name from filename (remove prefix and suffix)
# Input: oh-my-opencode-Name.json → Output: Name
get_display_name() {
    local filename="$1"
    local basename_name
    basename_name=$(basename "$filename")
    # Remove oh-my-opencode- prefix and .json suffix
    echo "${basename_name#oh-my-opencode-}" | sed 's/\.json$//'
}

# Get current active config by comparing content
get_current() {
    if [[ ! -f "$TARGET_FILE" ]]; then
        echo ""
        return
    fi

    local target_hash=$(md5 -q "$TARGET_FILE" 2>/dev/null)
    while IFS= read -r file; do
        local file_hash=$(md5 -q "$file" 2>/dev/null)
        if [[ "$target_hash" == "$file_hash" ]]; then
            basename "$file"
            return
        fi
    done < <(get_configs)
    echo ""
}

# Interactive menu with gum or fallback to ANSI
show_menu() {
    local configs=()
    local names=()

    while IFS= read -r file; do
        configs+=("$file")
        names+=("$(basename "$file")")
    done < <(get_configs)

    if [[ ${#configs[@]} -eq 0 ]]; then
        if command -v gum >/dev/null 2>&1; then
            setup_gum_theme
            gum style --foreground="#e5c07b" --margin "1 0" \
                "No oh-my-opencode-*.json config files found in $CONFIG_DIR"
        else
            echo -e "${YELLOW}No oh-my-opencode-*.json config files found in $CONFIG_DIR${NC}"
        fi
        exit 1
    fi

    local current=$(get_current)

    # Use gum if available
    if command -v gum >/dev/null 2>&1; then
        setup_gum_theme

        # Show styled header
        gum style \
            --border rounded \
            --border-foreground "#61afef" \
            --background "#282c34" \
            --margin "1 0" \
            --padding "2 4" \
            --align center \
            --width 50 \
            "⚡ Switch oh-my-opencode Configuration"

        # Prepare display names with active marker (show only the descriptive part)
        local display_names=()
        for name in "${names[@]}"; do
            local display_name
            display_name=$(get_display_name "$name")
            if [[ "$name" == "$current" ]]; then
                display_names+=("${display_name} ✓")
            else
                display_names+=("${display_name}")
            fi
        done

        # Use gum choose for selection
        local selected_display
        selected_display=$(printf "%s\n" "${display_names[@]}" | gum choose \
            --header "Select configuration (active marked with ✓):" \
            --height 15)

        # Check if user cancelled (empty selection)
        if [[ -z "$selected_display" ]]; then
            gum style --foreground "#5c6370" --margin "1 0" "Cancelled."
            exit 0
        fi

        # Extract original name (remove ✓ marker if present)
        local selected_name="${selected_display% ✓}"

        # Find selected index
        local selected_idx=-1
        for i in "${!names[@]}"; do
            if [[ "${names[$i]}" == "$selected_name" ]]; then
                selected_idx=$i
                break
            fi
        done

        if [[ $selected_idx -eq -1 ]]; then
            gum style --foreground "#e06c75" --margin "1 0" "Error: Selection not found"
            exit 1
        fi

        local selected_file="${configs[$selected_idx]}"

        # Check if already active
        if [[ "$selected_name" == "$current" ]]; then
            gum style --foreground "#e5c07b" --margin "1 0" \
                "$selected_name is already active."
            exit 0
        fi

        # Copy config
        cp "$selected_file" "$TARGET_FILE"

        if [[ $? -eq 0 ]]; then
            gum style \
                --border rounded \
                --border-foreground "#98c379" \
                --background "#282c34" \
                --margin "1 0" \
                --padding "1 2" \
                "✓ Switched to: $selected_name"
            gum style --foreground "#5c6370" --margin "0" \
                "Copied to: $TARGET_FILE"
        else
            gum style --foreground "#e06c75" --margin "1 0" \
                "✗ Error: Failed to copy config file"
            exit 1
        fi
    else
        # Fallback to original ANSI implementation
        local selected=0
        local total=${#configs[@]}

        # Hide cursor
        tput civis

        # Cleanup on exit
        trap 'tput cnorm; echo' EXIT INT TERM

        echo -e "${BOLD}Switch oh-my-opencode Configuration${NC}"
        echo -e "${DIM}Use arrow keys to navigate, Enter to select, q to quit${NC}"
        echo ""

        while true; do
            # Move cursor up to redraw menu
            if [[ $REPLY ]]; then
                tput cuu $total
            fi

            # Draw menu
            for i in "${!names[@]}"; do
                local name="${names[$i]}"
                local display_name
                display_name=$(get_display_name "$name")
                local marker="  "
                local color=""
                local suffix=""

                # Check if this is the currently active config
                if [[ "$name" == "$current" ]]; then
                    suffix=" ${GREEN}(active)${NC}"
                fi

                if [[ $i -eq $selected ]]; then
                    marker="${YELLOW}>${NC} "
                    color="${CYAN}"
                    echo -e "${marker}${color}${display_name}${NC}${suffix}"
                else
                    echo -e "  ${DIM}${display_name}${NC}${suffix}"
                fi
            done

            # Read single keypress
            read -rsn1 key

            # Handle arrow keys (escape sequences)
            if [[ $key == $'\x1b' ]]; then
                read -rsn2 key
                case $key in
                    '[A') # Up arrow
                        ((selected--))
                        [[ $selected -lt 0 ]] && selected=$((total - 1))
                        ;;
                    '[B') # Down arrow
                        ((selected++))
                        [[ $selected -ge $total ]] && selected=0
                        ;;
                esac
            elif [[ $key == "" ]]; then # Enter
                break
            elif [[ $key == "q" || $key == "Q" ]]; then
                tput cnorm
                echo ""
                echo -e "${DIM}Cancelled.${NC}"
                exit 0
            elif [[ $key == "j" ]]; then # vim down
                ((selected++))
                [[ $selected -ge $total ]] && selected=0
            elif [[ $key == "k" ]]; then # vim up
                ((selected--))
                [[ $selected -lt 0 ]] && selected=$((total - 1))
            fi

            REPLY=1
        done

        # Show cursor
        tput cnorm

        # Copy selected config
        local selected_file="${configs[$selected]}"
        local selected_name="${names[$selected]}"

        echo ""

        if [[ "$selected_name" == "$current" ]]; then
            echo -e "${YELLOW}$selected_name is already active.${NC}"
            exit 0
        fi

        cp "$selected_file" "$TARGET_FILE"

        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}Switched to: ${BOLD}$selected_name${NC}"
            echo -e "${DIM}Copied to: $TARGET_FILE${NC}"
        else
            echo -e "${YELLOW}Error: Failed to copy config file${NC}"
            exit 1
        fi
    fi
}

# Run
check_gum
show_menu
