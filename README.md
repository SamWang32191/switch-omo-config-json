# switch-omo-config-json

> 💡 **靈感來源**: [Switch-Omo-Config](https://github.com/AnPod/Switch-Omo-Config) by AnPod

一個簡潔優雅的 **oh-my-opencode** 設定檔切換工具，支援互動式選單與專案本地配置管理。

## 功能特色

- 🎨 **雙模式介面** - 自動偵測並使用 [gum](https://github.com/charmbracelet/gum) 現代化 TUI，無 gum 時自動降級為 ANSI 終端機介面
- 🗂️ **配置檔切換** - 快速在不同 oh-my-opencode 配置檔之間切換
- 📍 **專案本地配置** - 自動偵測並支援專案層級的 `.opencode` 目錄
- ☁️ **中央配置同步** - 可選將中央配置檔複製到專案目錄
- ✨ **視覺化回饋** - 即時顯示目前啟用的配置檔（使用 md5 比對）
- 🎯 **One Dark Pro 配色** - 使用 VS Code 熱門主題的配色方案

## 快速開始

### 安裝需求

- **bash** (必需)
- **gum** (選用，推薦安裝以獲得最佳體驗):
  ```bash
  brew install gum
  ```
- **md5** (macOS 內建) 或 **md5sum** (Linux)

### 使用方法

1. **執行腳本**:
   ```bash
   ./switch-omo-config.sh
   ```

2. **選擇配置檔**:
   - 使用方向鍵或 `j`/`k` (vim 模式) 移動
   - 按 `Enter` 確認選擇
   - 按 `q` 取消

3. **專案本地配置** (首次執行時詢問):
   - 若偵測到當前目錄有 `.opencode` 目錄，將自動使用專案本地配置
   - 若無，會詢問是否要建立，並記住你的選擇

## 配置檔結構

```
switch-omo-config-json/
├── switch-omo-config.sh              # 主執行腳本
├── oh-my-opencode-Antigravity.json   # 輕量級配置
├── oh-my-opencode-CAO.json           # CAO 專用配置
├── oh-my-opencode-CAO-Full.json      # CAO 完整配置
├── oh-my-opencode-Free.json          # 免費模型配置
├── oh-my-opencode-AntigravityAndFree.json  # 混合配置
└── .switch-omo-config.create-opencode      # 用戶偏好標記檔
```

## 配置檔說明

| 配置檔 | 說明 |
|--------|------|
| `Antigravity` | 輕量級配置，使用 Gemini Flash 等免費/輕量模型 |
| `Free` | 完全免費模型配置 |
| `CAO` | 平衡效能與成本的配置 |
| `CAO-Full` | 完整功能配置，使用 Claude Opus 等高性能模型 |
| `AntigravityAndFree` | 混合配置，兼顧輕量與免費 |

## 運作原理

1. **配置檔來源**: 從 `$HOME/.config/opencode/` (中央) 或 `./.opencode/` (專案本地) 讀取 `oh-my-opencode-*.json`
2. **目標檔案**: 將選擇的配置檔複製為 `oh-my-opencode.json`
3. **目前配置偵測**: 使用 md5 雜湊比對，在選單中標記 ✓ 顯示目前啟用的配置

## 自訂配置

### 新增自定義配置檔

1. 建立新的 JSON 檔案，命名為 `oh-my-opencode-YourName.json`
2. 放入配置目錄 (`~/.config/opencode/` 或專案 `.opencode/`)
3. 執行腳本即可看到新配置

### 配置檔格式

參考 [oh-my-opencode 官方文件](https://github.com/code-yeongyu/oh-my-opencode)，配置檔包含:

- `agents`: 各代理的模型與提示詞設定
- `categories`: 委派類別的模型設定
- `sisyphus_agent`: Sisyphus 代理行為設定
- `git_master`: Git 相關設定

## 常見問題

**Q: 為什麼首次執行會問我要不要建立 `.opencode`？**
A: 這是為了支援專案本地配置。若選「是」，後續在此專案執行腳本時會優先使用專案內的配置檔。

**Q: 如何清除已記住的选择？**
A: 刪除 `.switch-omo-config.create-opencode` 檔案即可重新選擇。

**Q: 沒有安裝 gum 能用嗎？**
A: 可以！腳本會自動使用 ANSI 傳統介面，支援方向鍵與 vim 鍵位 (`j`/`k`)。

## 授權

MIT License - 自由使用與修改

---

**讓你的 oh-my-opencode 配置切換更優雅！** ⚡
