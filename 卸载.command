#!/bin/bash
# Seagull Uninstall (macOS)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

USER_HOME="$HOME"
CLAUDE_DIR="$USER_HOME/.claude"

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${YELLOW}  Seagull Uninstall (macOS)${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Also check desktop version dirs
ALL_DIRS=("$CLAUDE_DIR")
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

echo -e "${YELLOW}This will remove Seagull configuration from:${NC}"
for d in "${ALL_DIRS[@]}"; do
    echo -e "${GRAY}  - $d${NC}"
done
echo ""

read -p "Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    read -p "Press Enter to exit..."
    exit 0
fi

total_removed=0

remove_count() { total_removed=$((total_removed + 1)); }

for dir in "${ALL_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${CYAN}[*] Cleaning: $dir${NC}"
        for f in CLAUDE.md system-prompt.md config.toml; do
            if [ -f "$dir/$f" ]; then
                if rm -f "$dir/$f" 2>/dev/null; then
                    echo -e "${GREEN}    Removed $f${NC}"
                    remove_count
                else
                    echo -e "${RED}    Failed to remove $f${NC}"
                fi
            else
                echo -e "${GRAY}    $f not found${NC}"
            fi
        done
    fi
done

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}  Removed $total_removed files${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
read -p "Press Enter to exit..."
