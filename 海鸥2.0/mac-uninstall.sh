#!/bin/bash
# 海鸥2.0 Mac卸载
# 使用方法：打开终端，把这个文件拖进去，回车

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
xattr -cr "$SCRIPT_DIR" 2>/dev/null

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

USER_HOME="$HOME"
CLAUDE_DIR="$USER_HOME/.claude"

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${RED}  海鸥卸载 (macOS)${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

ALL_DIRS=("$CLAUDE_DIR")
for candidate in \
    "$USER_HOME/Library/Application Support/claude" \
    "$USER_HOME/Library/Application Support/claude-code" \
    "$USER_HOME/Library/Application Support/Claude" \
    "$USER_HOME/Library/Application Support/Claude Code"; do
    if [ -d "$candidate" ] && [ "$candidate" != "$CLAUDE_DIR" ]; then
        ALL_DIRS+=("$candidate")
    fi
done

echo -e "${GRAY}将从以下目录删除配置:${NC}"
for d in "${ALL_DIRS[@]}"; do
    echo -e "${GRAY}  - $d${NC}"
done
echo ""

read -p "确认卸载? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "已取消。"
    read -p "按回车退出..."
    exit 0
fi

total=0
for dir in "${ALL_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${CYAN}[*] 清理: $dir${NC}"
        for f in CLAUDE.md system-prompt.md config.toml; do
            if [ -f "$dir/$f" ]; then
                rm -f "$dir/$f" 2>/dev/null
                echo -e "${GREEN}    已删除 $f${NC}"
                total=$((total + 1))
            fi
        done
    fi
done

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}  卸载完成，共删除 $total 个文件${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
read -p "按回车退出..."
