#!/bin/bash
# 海鸥2.0 Linux卸载

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

CLAUDE_DIR="$HOME/.claude"

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${RED}  海鸥卸载 (Linux)${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

echo -e "${GRAY}将删除以下文件:${NC}"
echo -e "${GRAY}  - $CLAUDE_DIR/CLAUDE.md${NC}"
echo -e "${GRAY}  - $CLAUDE_DIR/system-prompt.md${NC}"
echo -e "${GRAY}  - $CLAUDE_DIR/config.toml${NC}"
echo ""

read -p "确认卸载? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "已取消。"
    exit 0
fi

# 备份
date=$(date +%Y%m%d-%H%M%S)
backup="$CLAUDE_DIR/backups/seagull-$date"
mkdir -p "$backup" 2>/dev/null

removed=0
for f in CLAUDE.md system-prompt.md config.toml; do
    if [ -f "$CLAUDE_DIR/$f" ]; then
        cp "$CLAUDE_DIR/$f" "$backup/$f" 2>/dev/null
        rm -f "$CLAUDE_DIR/$f" 2>/dev/null
        echo -e "${GREEN}    已删除: $f${NC}"
        removed=$((removed + 1))
    else
        echo -e "${GRAY}    不存在: $f${NC}"
    fi
done

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}  卸载完成，共删除 $removed 个文件${NC}"
echo -e "${GRAY}  备份: $backup${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
