#!/bin/bash
# 切換 oh-my-opencode 設定檔
# 用法：./switch-omo-config.sh

# 檢查 gum 是否安裝，若未安裝則結束
check_gum() {
    if ! command -v gum >/dev/null 2>&1; then
        echo "錯誤：此腳本需要 'gum' 才能執行。"
        echo "請先安裝 gum："
        echo "  brew install gum"
        echo ""
        echo "其他安裝方式請參考：https://github.com/charmbracelet/gum"
        exit 1
    fi
}

# 依據 macOS 系統外觀偵測終端機主題（亮/暗）
# 回傳：設定全域 THEME_MODE 為 "dark" 或 "light"
detect_terminal_theme() {
    # 檢查是否為 macOS（是否有 defaults 指令）
    if ! command -v defaults >/dev/null 2>&1; then
        # 非 macOS - 為相容性預設為暗色
        THEME_MODE="dark"
        return
    fi

    # 在 macOS：AppleInterfaceStyle = "Dark" 代表深色模式
    # 亮色模式時此鍵不存在（系統預設）
    local appearance
    appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
    
    if [[ "$appearance" == "Dark" ]]; then
        THEME_MODE="dark"
    else
        # 鍵不存在或其他值 = 亮色模式
        THEME_MODE="light"
    fi
}

# 設定 Gum 主題 - 支援 One Dark Pro（暗）與 One Light Pro（亮）
setup_gum_theme() {
    # 若尚未設定則偵測主題
    if [[ -z "$THEME_MODE" ]]; then
        detect_terminal_theme
    fi

    # 依主題選色盤
    if [[ "$THEME_MODE" == "light" ]]; then
        # One Light Pro 色盤
        local bg="#fafafa"           # 背景
        local fg="#383a42"           # 前景文字
        local blue="#4078f2"         # 主色（藍）
        local green="#50a14f"        # 成功（綠）
        local red="#e45649"          # 錯誤（紅）
        local yellow="#c18401"       # 警告（黃）
        local purple="#a626a4"       # 次要色（紫）
        local cyan="#0184bc"         # 第三色（青）
        local muted="#a0a1a7"        # 輔助文字
        local unselected_bg="#e5e5e6" # 未選取按鈕背景
    else
        # One Dark Pro 色盤（預設）
        local bg="#282c34"           # 背景
        local fg="#abb2bf"           # 前景文字
        local blue="#61afef"         # 主色（藍）
        local green="#98c379"        # 成功（綠）
        local red="#e06c75"          # 錯誤（紅）
        local yellow="#e5c07b"       # 警告（黃）
        local purple="#c678dd"       # 次要色（紫）
        local cyan="#56b6c2"         # 第三色（青）
        local muted="#5c6370"        # 輔助文字
        local unselected_bg="#3e4451" # 未選取按鈕背景
    fi

    # 匯出主題色供 show_menu 使用
    export THEME_BG="$bg"
    export THEME_FG="$fg"
    export THEME_BLUE="$blue"
    export THEME_GREEN="$green"
    export THEME_RED="$red"
    export THEME_YELLOW="$yellow"
    export THEME_PURPLE="$purple"
    export THEME_CYAN="$cyan"
    export THEME_MUTED="$muted"

    # 外觀設定
    export GUM_STYLE_BORDER="rounded"
    export GUM_STYLE_BORDER_FOREGROUND="$blue"
    export GUM_STYLE_FOREGROUND="$fg"
    export GUM_STYLE_BACKGROUND="$bg"
    export GUM_STYLE_MARGIN="1 0"
    export GUM_STYLE_PADDING="2 4"

    # 選單設定
    export GUM_CHOOSE_CURSOR_FOREGROUND="$blue"
    export GUM_CHOOSE_ITEM_FOREGROUND="$fg"
    export GUM_CHOOSE_SELECTED_FOREGROUND="$green"
    export GUM_CHOOSE_HEADER_FOREGROUND="$cyan"
    export GUM_CHOOSE_CURSOR="→ "
    export GUM_CHOOSE_SELECTED_PREFIX="✓ "
    export GUM_CHOOSE_UNSELECTED_PREFIX="  "
    export GUM_CHOOSE_HEIGHT=15

    # 確認對話框設定
    export GUM_CONFIRM_PROMPT_FOREGROUND="$fg"
    export GUM_CONFIRM_SELECTED_FOREGROUND="$bg"
    export GUM_CONFIRM_SELECTED_BACKGROUND="$green"
    export GUM_CONFIRM_UNSELECTED_FOREGROUND="$fg"
    export GUM_CONFIRM_UNSELECTED_BACKGROUND="$unselected_bg"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CENTRAL_CONFIG_DIR="$HOME/.config/opencode"
PROJECT_ROOT_DIR="$PWD"
PROJECT_CONFIG_DIR="$PROJECT_ROOT_DIR/.opencode"

CONFIG_DIR="$CENTRAL_CONFIG_DIR"
TARGET_FILE="$CONFIG_DIR/oh-my-opencode.json"

use_project_config_dir="false"

if [[ -d "$PROJECT_CONFIG_DIR" ]]; then
    setup_gum_theme
    gum style --margin "1 0" --padding "1 2" \
        "偵測到專案已有 .opencode：$PROJECT_CONFIG_DIR"
    selected_scope=$(gum choose "專案" "全域")
    if [[ "$selected_scope" == "專案" ]]; then
        use_project_config_dir="true"
    else
        use_project_config_dir="false"
    fi
else
    PROJECT_CREATE_CHOICE_FILE="$PROJECT_ROOT_DIR/.switch-omo-config.create-opencode"

    create_opencode=""
    if [[ -f "$PROJECT_CREATE_CHOICE_FILE" ]]; then
        create_opencode=$(tr -d ' \t\r\n' < "$PROJECT_CREATE_CHOICE_FILE")
    fi

    if [[ ! "$create_opencode" =~ ^[YyNn]$ ]]; then
            setup_gum_theme
            gum style --margin "1 0" --padding "1 2" \
                "未在以下路徑偵測到 .opencode：$PROJECT_ROOT_DIR"
            if gum confirm "要在此專案建立 .opencode 以使用專案層級切換嗎？" \
                --default=false --affirmative "是" --negative "否"; then
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
            echo "錯誤：無法建立 $PROJECT_CONFIG_DIR（請檢查權限）"
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
                "偵測到 .opencode：$PROJECT_CONFIG_DIR"
            if gum confirm "要將全域的 oh-my-opencode-*.json 設定檔複製到專案目錄嗎？" \
                --default=false --affirmative "是" --negative "否"; then
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

# 先設定 gum 主題
setup_gum_theme

# 取得設定檔清單（排除主檔）
get_configs() {
    {
        find "$CONFIG_DIR" -maxdepth 1 -name "oh-my-opencode-*.json" -type f 2>/dev/null
        find "$SCRIPT_DIR/configs" -maxdepth 1 -name "oh-my-opencode-*.json" -type f 2>/dev/null
    } | sort -u
}

# 從檔名取出顯示名稱（移除前綴與副檔名）
# 輸入：oh-my-opencode-Name.json → 輸出：Name
get_display_name() {
    local filename="$1"
    local basename_name
    basename_name=$(basename "$filename")
    # 移除 oh-my-opencode- 前綴與 .json 副檔名
    echo "${basename_name#oh-my-opencode-}" | sed 's/\.json$//'
}

# 透過內容比對取得目前啟用的設定
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

# 使用 gum 顯示互動選單
show_menu() {
    local configs=()
    local names=()

    while IFS= read -r file; do
        configs+=("$file")
        names+=("$(basename "$file")")
    done < <(get_configs)

    if [[ ${#configs[@]} -eq 0 ]]; then
        setup_gum_theme
        gum style --foreground="$THEME_YELLOW" --margin "1 0" \
            "在 $CONFIG_DIR 找不到 oh-my-opencode-*.json 設定檔"
        exit 1
    fi

    local current=$(get_current)

    setup_gum_theme

    # 顯示標題
        gum style \
            --border rounded \
            --border-foreground "$THEME_BLUE" \
            --background "$THEME_BG" \
            --margin "1 0" \
            --padding "2 4" \
            --align center \
            --width 50 \
            "⚡ 切換 oh-my-opencode 設定"

        # 準備含狀態標記的顯示名稱（僅顯示描述部分）
        local display_names=()
        for name in "${names[@]}"; do
            local display_name
            display_name=$(get_display_name "$name")
            if [[ "$name" == "$current" ]]; then
                display_names+=("● ${display_name}")
            else
                display_names+=("○ ${display_name}")
            fi
        done

        # 使用 gum choose 選擇
        local selected_display
        selected_display=$(printf "%s\n" "${display_names[@]}" | gum choose \
            --header "選擇設定（● = 已啟用，○ = 未啟用）：" \
            --height 15)

        # 使用者取消（空選擇）
        if [[ -z "$selected_display" ]]; then
            gum style --foreground "$THEME_MUTED" --margin "1 0" "已取消。"
            exit 0
        fi

        # 取出原始名稱（移除標記）
        local selected_name="${selected_display#● }"
        selected_name="${selected_name#○ }"

        # 尋找選取索引
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
            gum style --foreground "$THEME_RED" --margin "1 0" "錯誤：找不到選取項目"
            exit 1
        fi

        local selected_file="${configs[$selected_idx]}"
        local selected_basename="${names[$selected_idx]}"

        # 已經啟用
        if [[ "$selected_basename" == "$current" ]]; then
            gum style --foreground "$THEME_YELLOW" --margin "1 0" \
                "$selected_name 已是目前啟用的配置。"
            exit 0
        fi

        # 複製設定檔
        cp "$selected_file" "$TARGET_FILE"

        if [[ $? -eq 0 ]]; then
            gum style \
                --border rounded \
                --border-foreground "$THEME_GREEN" \
                --background "$THEME_BG" \
                --margin "1 0" \
                --padding "1 2" \
                "✓ 已切換為：$selected_name"
            gum style --foreground "$THEME_MUTED" --margin "0" \
                "已複製到：$TARGET_FILE"
        else
            gum style --foreground "$THEME_RED" --margin "1 0" \
                "✗ 錯誤：複製設定檔失敗"
            exit 1
        fi
}

# 執行
check_gum
show_menu
