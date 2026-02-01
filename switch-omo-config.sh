#!/bin/bash
# Switch oh-my-opencode configuration profiles
# Usage: ./switch-omo-config.sh

# Check if gum is installed, exit if not
check_gum() {
    if ! command -v gum >/dev/null 2>&1; then
        echo "Error: This script requires 'gum' to run."
        echo "Please install gum first:"
        echo "  brew install gum"
        echo ""
        echo "For other installation options, see: https://github.com/charmbracelet/gum"
        exit 1
    fi
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

# Setup gum theme early
setup_gum_theme

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

# Interactive menu using gum
show_menu() {
    local configs=()
    local names=()

    while IFS= read -r file; do
        configs+=("$file")
        names+=("$(basename "$file")")
    done < <(get_configs)

    if [[ ${#configs[@]} -eq 0 ]]; then
        setup_gum_theme
        gum style --foreground="#e5c07b" --margin "1 0" \
            "No oh-my-opencode-*.json config files found in $CONFIG_DIR"
        exit 1
    fi

    local current=$(get_current)

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
            local name_display
            name_display=$(get_display_name "${names[$i]}")
            if [[ "$name_display" == "$selected_name" ]]; then
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
}

# Run
check_gum
show_menu
