#!/bin/bash
# Seagull Deploy v1.0 for macOS
# Deploys Claude Code personality config

set -uo pipefail

# Fix: arithmetic increment returns 1 when value is 0, which kills script with set -e
# Use helper functions instead
inc_ok()   { ok=$((ok + 1)); }
inc_fail() { fail=$((fail + 1)); }
inc_count(){ count=$((count + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUNDLE_DIR="$SCRIPT_DIR/claude-config-bundle"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}  Seagull Deploy v1.0 (macOS)${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Detect user home
USER_HOME="$HOME"
echo -e "${GRAY}[*] User: $(whoami)${NC}"
echo -e "${GRAY}[*] Home: $USER_HOME${NC}"
echo -e "${GRAY}[*] macOS: $(sw_vers -productVersion 2>/dev/null || echo 'unknown')${NC}"

# ========== Detect ALL config directories ==========
CLAUDE_DIR="$USER_HOME/.claude"
ALL_DIRS=("$CLAUDE_DIR")

# macOS desktop version candidates
DESKTOP_CANDIDATES=(
    "$USER_HOME/Library/Application Support/claude"
    "$USER_HOME/Library/Application Support/claude-code"
    "$USER_HOME/Library/Application Support/Claude"
    "$USER_HOME/Library/Application Support/Claude Code"
    "$USER_HOME/Library/Preferences/claude"
    "$USER_HOME/Library/Preferences/claude-code"
)

for candidate in "${DESKTOP_CANDIDATES[@]}"; do
    if [ -d "$candidate" ] && [ "$candidate" != "$CLAUDE_DIR" ]; then
        ALL_DIRS+=("$candidate")
    fi
done

echo -e "${GRAY}[*] Config directories found: ${#ALL_DIRS[@]}${NC}"
for d in "${ALL_DIRS[@]}"; do
    echo -e "${GRAY}    $d${NC}"
done
echo ""

# ========== Check source files ==========
if [ ! -d "$BUNDLE_DIR" ]; then
    echo -e "${RED}[!] Source directory not found: $BUNDLE_DIR${NC}"
    echo -e "${RED}    Make sure claude-config-bundle/ exists next to this script${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

if [ ! -f "$BUNDLE_DIR/CLAUDE.md" ]; then
    echo -e "${RED}[!] CLAUDE.md not found in $BUNDLE_DIR${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

if [ ! -f "$BUNDLE_DIR/system-prompt.md" ]; then
    echo -e "${RED}[!] system-prompt.md not found in $BUNDLE_DIR${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

# ========== Deploy function ==========
deploy_to_dir() {
    local dst="$1"
    local ok=0
    local fail=0

    # Ensure directory exists
    if [ ! -d "$dst" ]; then
        mkdir -p "$dst" 2>/dev/null || {
            echo -e "${RED}[!] Failed to create: $dst${NC}"
            return 1
        }
        echo -e "${YELLOW}[+] Created directory: $dst${NC}"
    fi

    # 1. CLAUDE.md
    echo -e "${YELLOW}[1/4] CLAUDE.md...${NC}"
    if cp "$BUNDLE_DIR/CLAUDE.md" "$dst/CLAUDE.md" 2>/dev/null; then
        local size=$(wc -c < "$dst/CLAUDE.md" | tr -d ' ')
        echo -e "${GREEN}    OK ($size bytes)${NC}"
        inc_ok
    else
        echo -e "${RED}    FAIL${NC}"
        inc_fail
    fi

    # 2. system-prompt.md
    echo -e "${YELLOW}[2/4] system-prompt.md...${NC}"
    if cp "$BUNDLE_DIR/system-prompt.md" "$dst/system-prompt.md" 2>/dev/null; then
        local size=$(wc -c < "$dst/system-prompt.md" | tr -d ' ')
        echo -e "${GREEN}    OK ($size bytes)${NC}"
        inc_ok
    else
        echo -e "${RED}    FAIL${NC}"
        inc_fail
    fi

    # 3. settings.json (only if not exists)
    echo -e "${YELLOW}[3/4] settings.json...${NC}"
    if [ ! -f "$dst/settings.json" ]; then
        cat > "$dst/settings.json" << 'SETTINGS_EOF'
{
  "effortLevel": "xhigh",
  "env": {
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "DISABLE_AUTOUPDATER": "1"
  },
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "skipDangerousModePermissionPrompt": true
}
SETTINGS_EOF
        if [ -f "$dst/settings.json" ]; then
            echo -e "${GREEN}    OK (bypassPermissions)${NC}"
            inc_ok
        else
            echo -e "${RED}    FAIL${NC}"
            inc_fail
        fi
    else
        echo -e "${GRAY}    SKIPPED (exists)${NC}"
        inc_ok
    fi

    # 4. config.toml
    echo -e "${YELLOW}[4/4] config.toml...${NC}"
    echo 'model_instructions_file = "system-prompt.md"' > "$dst/config.toml" 2>/dev/null
    if [ -f "$dst/config.toml" ]; then
        echo -e "${GREEN}    OK${NC}"
        inc_ok
    else
        echo -e "${RED}    FAIL${NC}"
        inc_fail
    fi

    echo -e "${GRAY}    Result: $ok ok, $fail fail${NC}"
    return $fail
}

# ========== Backup function ==========
backup_dir="$CLAUDE_DIR/backups"
backup_config() {
    local dst="$1"
    local date=$(date +%Y%m%d-%H%M%S)
    local backup_path="$dst/backups/seagull-$date"
    local count=0

    for f in CLAUDE.md system-prompt.md config.toml settings.json; do
        if [ -f "$dst/$f" ]; then
            mkdir -p "$backup_path" 2>/dev/null
            if cp "$dst/$f" "$backup_path/$f" 2>/dev/null; then
                inc_count
            fi
        fi
    done

    if [ $count -gt 0 ]; then
        echo -e "${GRAY}[*] Backed up $count existing files${NC}"
    fi
}

# ========== Main deploy ==========
echo -e "${CYAN}Deploying to primary directory...${NC}"
backup_config "$CLAUDE_DIR"
deploy_to_dir "$CLAUDE_DIR"

# Deploy to all other detected directories
for dir in "${ALL_DIRS[@]}"; do
    if [ "$dir" != "$CLAUDE_DIR" ]; then
        echo ""
        echo -e "${CYAN}[*] Deploying to: $dir${NC}"
        deploy_to_dir "$dir"
    fi
done

# ========== Summary ==========
echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}  Deploy complete!${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo -e "${CYAN}  Restart Claude Code and test.${NC}"
echo -e "${CYAN}  Terminal: run 'claude' in Terminal${NC}"
echo -e "${CYAN}  Desktop:  open Claude desktop app${NC}"
echo ""
read -p "Press Enter to exit..."
