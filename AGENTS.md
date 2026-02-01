# AGENTS.md - switch-omo-config-json

This is a **bash/shell script** project for managing oh-my-opencode configuration profiles.

## Project Structure

```
switch-omo-config-json/
├── switch-omo-config.sh          # Main executable script
├── oh-my-opencode-*.json         # Profile configurations (5 variants)
└── .switch-omo-config.create-opencode  # User preference flag
```

## Build/Lint/Test Commands

**No formal build system** - this is a pure shell script project.

### Manual Verification
```bash
# Check bash syntax
bash -n switch-omo-config.sh

# Run shellcheck (if available)
shellcheck switch-omo-config.sh

# Test the script (dry run - just shows menu)
./switch-omo-config.sh

# Test specific function
cd test-sandbox && bash -c 'source ../switch-omo-config.sh; check_gum'
```

### Prerequisites
- `bash` (required)
- `gum` (required): `brew install gum`
- `md5` (macOS) or `md5sum` (Linux) for hash comparison

## Code Style Guidelines

### Bash/Shell Conventions

**Indentation & Formatting**
- Use 4-space indentation
- Use `#!/bin/bash` shebang explicitly
- Maximum line length: 100 characters where practical

**Naming Conventions**
- Functions: `snake_case()` - e.g., `check_gum()`, `setup_gum_theme()`
- Local variables: `snake_case` - e.g., `local bg="#282c34"`
- Constants/Colors: `UPPERCASE` - e.g., `CYAN`, `TARGET_FILE`
- Script globals: `UPPERCASE_SNAKE_CASE` with `_DIR`/`_FILE` suffixes

**Variable Usage**
- Always use `local` for function-local variables
- Always quote variables: `"$variable"` not `$variable`
- Use `[[ ... ]]` for conditionals (bash-specific, not POSIX `[`)
- Use `(( ... ))` for arithmetic

**Error Handling**
- Check command existence: `command -v tool >/dev/null 2>&1`
- Check exit codes explicitly where critical: `if [[ $? -eq 0 ]]; then`
- Use `trap` for cleanup: `trap 'tput cnorm; echo' EXIT INT TERM`
- Never use `set -e` (script uses explicit error handling instead)

**File Operations**
- Use `printf` for writing to files: `printf '%s\n' "y" > "$file"`
- Use `mkdir -p` before file creation
- Check file existence before operations: `[[ -f "$file" ]]` or `[[ -d "$dir" ]]`

**JSON Handling**
- No jq dependency - JSON files are treated as opaque blobs
- Use `md5 -q` (macOS) or `md5sum` (Linux) for content comparison

### Comments & Documentation
- Use `#` for comments
- Add brief function description comments
- Use `##` for section headers within the script

### UI Patterns
- Uses `gum` for all interactive UI elements
- Gum theme setup in dedicated `setup_gum_theme()` function
- One Dark Pro color palette

### Safety Rules
- **NEVER** use `eval` on user input
- **NEVER** use `rm -rf` with variables without checks
- **ALWAYS** validate file paths before operations
- **ALWAYS** check required dependencies (`gum`) at startup and exit with clear error message if missing

## JSON Profile Structure

Profile files follow the oh-my-opencode schema:
- Schema URL in `$schema` field
- Agent configurations under `agents` key
- Category configurations under `categories` key
- Model variants specified per agent/category
- All prompts include Traditional Chinese requirement: `ALWAYS answer in Traditional Chinese(zh_TW)`

## Git Workflow

- No CI/CD configured
- No automated tests to run before commit
- Manual testing recommended: verify script runs without syntax errors
