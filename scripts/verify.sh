#!/bin/bash
# Seagull Verify (macOS)

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

USER_HOME="$HOME"
CLAUDE_DIR="$USER_HOME/.claude"

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  Seagull Verify (macOS)${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

all_ok=true

check_file() {
    local file="$1"
    local pattern="$2"
    local label="$3"
    local path="$CLAUDE_DIR/$file"

    if [ -f "$path" ]; then
        local size=$(wc -c < "$path" | tr -d ' ')
        if grep -q "$pattern" "$path" 2>/dev/null; then
            echo -e "${GREEN}  $file - OK ($size bytes)${NC}"
        else
            echo -e "${YELLOW}  $file - WARNING ($size bytes, pattern not found)${NC}"
            all_ok=false
        fi
    else
        echo -e "${RED}  $file - MISSING${NC}"
        all_ok=false
    fi
}

echo "Checking $CLAUDE_DIR..."
check_file "CLAUDE.md" "海鸥在线" "Greeting"
check_file "system-prompt.md" "海鸥" "Content"
check_file "settings.json" "bypassPermissions" "Permissions"
check_file "config.toml" "system-prompt.md" "Pointer"

echo ""
if $all_ok; then
    echo -e "${GREEN}All checks passed!${NC}"
else
    echo -e "${YELLOW}Some checks failed. Run install first.${NC}"
fi
echo ""
read -p "Press Enter to exit..."
