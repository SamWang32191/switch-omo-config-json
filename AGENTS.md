# switch-omo-config-json 專案知識庫

**生成時間**: 2026-02-01
**專案類型**: Bash 工具腳本
**授權**: MIT

## 專案概述

oh-my-opencode 設定檔切換工具，提供互動式 TUI 選單（使用 gum）與專案本地配置管理。核心功能：掃描 configs/ 目錄的設定檔，透過 md5 比對偵測目前啟用配置，複製選擇的檔案為作用中設定。

## 專案結構

```
.
├── switch-omo-config.sh    # 主腳本 (283 行)
├── configs/                # 設定檔目錄
│   ├── oh-my-opencode-Free.json
│   ├── oh-my-opencode-Antigravity.json
│   ├── oh-my-opencode-Antigravity_Free.json
│   ├── oh-my-opencode-ChatGPT_Antigravity_OpenCode.json
│   └── oh-my-opencode-ChatGPT_Antigravity_OpenCode_FULL.json
├── README.md               # 使用說明
└── LICENSE                 # MIT 授權
```

## 關鍵檔案

| 檔案                   | 用途   | 說明                              |
| ---------------------- | ------ | --------------------------------- |
| `switch-omo-config.sh` | 主程式 | 互動式配置切換邏輯                |
| `configs/*.json`       | 設定檔 | oh-my-opencode 代理與類別模型設定 |

## 設定檔類型

設定檔包含兩大類模型設定：

**免費版 (Free)**：使用 OpenCode 免費模型
- sisyphus: `opencode/kimi-k2.5-free`
- ultrabrain: `opencode/glm-4.7-free`
- quick/unspecified-low: `opencode/minimax-m2.1-free`

**Antigravity 版**：使用 Antigravity/OpenAI 付費模型
- sisyphus: `google/antigravity-claude-opus-4-5-thinking`
- ultrabrain: `openai/gpt-5.2-codex`
- oracle: `openai/gpt-5.2`
- quick: `google/antigravity-gemini-3-flash`

所有設定檔統一附加：`ALWAYS use the QUESTION TOOL if you need to ask user. ALWAYS answer in Traditional Chinese(zh_TW).`

## 腳本運作機制

1. **配置來源掃描**：搜尋 `$SCRIPT_DIR/configs/` 的 `oh-my-opencode-*.json`
2. **目前配置偵測**：使用 `md5 -q` 比對 `$TARGET_FILE` 與各設定檔雜湊值
3. **互動選單**：gum choose 顯示清單，目前啟用標記 ✓
4. **切換執行**：`cp $selected_file $TARGET_FILE`

## 依賴

- **gum**: 必要，提供互動式 TUI (`brew install gum`)
- **md5**: macOS 內建，Linux 可用 md5sum

## 使用方式

```bash
./switch-omo-config.sh
```

首次執行會詢問是否建立專案本地 `.opencode` 目錄。

## 約定

- 設定檔命名：`oh-my-opencode-{Name}.json`
- 顯示名稱：移除前綴與 `.json` 後綴
- One Dark Pro 配色主題（藍 #61afef、綠 #98c379、紅 #e06c75）

## 注意事項

- 腳本修改 `configs/` 路徑後，確保 `find "$SCRIPT_DIR/configs"` 正確運作
- 設定檔為純 JSON，無邏輯，僅供 oh-my-opencode 讀取
- 所有輸出使用繁體中文 (zh_TW)
