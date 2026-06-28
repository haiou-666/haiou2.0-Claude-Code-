#!/bin/bash
# 海鸥2.0 Linux部署

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUNDLE_DIR="$SCRIPT_DIR/claude-config-bundle"
CLAUDE_DIR="$HOME/.claude"
ERRORS=0
DEPLOYED=0

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}  海鸥 Deploy v1.0 (Linux)${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

echo -e "${GRAY}[*] 用户: $(whoami)${NC}"
echo -e "${GRAY}[*] 系统: $(uname -s) $(uname -r)${NC}"
echo -e "${GRAY}[*] 目标: $CLAUDE_DIR${NC}"
echo ""

# 检查源文件
if [ ! -f "$BUNDLE_DIR/CLAUDE.md" ]; then
    echo -e "${RED}[X] 找不到 CLAUDE.md${NC}"
    echo -e "${RED}    路径: $BUNDLE_DIR/CLAUDE.md${NC}"
    exit 1
fi

# 检查claude是否安装
if ! command -v claude &>/dev/null; then
    echo -e "${YELLOW}[!] 未检测到 claude 命令${NC}"
    echo -e "${GRAY}    请先安装: npm install -g @anthropic-ai/claude-code${NC}"
    echo ""
    read -p "是否自动安装? (Y/N): " INSTALL
    if [[ "$INSTALL" =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}[*] 正在安装 claude...${NC}"
        npm install -g @anthropic-ai/claude-code
        if [ $? -ne 0 ]; then
            echo -e "${RED}[X] 安装失败，请手动安装${NC}"
            exit 1
        fi
        echo -e "${GREEN}[+] 安装成功${NC}"
    else
        echo -e "${RED}[X] 请先安装 claude 再运行部署${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}[+] claude 已安装${NC}"
echo ""

# 创建目录
mkdir -p "$CLAUDE_DIR"

# 备份
date=$(date +%Y%m%d-%H%M%S)
backup="$CLAUDE_DIR/backups/seagull-$date"
backed=0
for f in CLAUDE.md system-prompt.md config.toml settings.json; do
    if [ -f "$CLAUDE_DIR/$f" ]; then
        mkdir -p "$backup" 2>/dev/null
        cp "$CLAUDE_DIR/$f" "$backup/$f" 2>/dev/null && backed=$((backed + 1))
    fi
done
[ $backed -gt 0 ] && echo -e "${GRAY}[*] 已备份 $backed 个文件${NC}"

# 部署函数
deploy() {
    local dst="$1"
    local label="$2"
    mkdir -p "$dst" 2>/dev/null

    # 1. CLAUDE.md
    echo -e "${YELLOW}  [1/4] CLAUDE.md${NC}"
    if cp "$BUNDLE_DIR/CLAUDE.md" "$dst/CLAUDE.md" 2>/dev/null; then
        local size=$(wc -c < "$dst/CLAUDE.md" | tr -d ' ')
        echo -e "${GREEN}        OK ($size bytes)${NC}"
        DEPLOYED=$((DEPLOYED + 1))
    else
        echo -e "${RED}        FAIL${NC}"
        ERRORS=$((ERRORS + 1))
    fi

    # 2. system-prompt.md
    echo -e "${YELLOW}  [2/4] system-prompt.md${NC}"
    if cp "$BUNDLE_DIR/system-prompt.md" "$dst/system-prompt.md" 2>/dev/null; then
        local size=$(wc -c < "$dst/system-prompt.md" | tr -d ' ')
        echo -e "${GREEN}        OK ($size bytes)${NC}"
        DEPLOYED=$((DEPLOYED + 1))
    else
        echo -e "${RED}        FAIL${NC}"
        ERRORS=$((ERRORS + 1))
    fi

    # 3. settings.json
    echo -e "${YELLOW}  [3/4] settings.json${NC}"
    if [ ! -f "$dst/settings.json" ]; then
        cat > "$dst/settings.json" << 'EOF'
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
EOF
        echo -e "${GREEN}        OK${NC}"
        DEPLOYED=$((DEPLOYED + 1))
    else
        echo -e "${GRAY}        已存在，跳过${NC}"
    fi

    # 4. config.toml
    echo -e "${YELLOW}  [4/4] config.toml${NC}"
    echo 'model_instructions_file = "system-prompt.md"' > "$dst/config.toml" 2>/dev/null
    echo -e "${GREEN}        OK${NC}"
    DEPLOYED=$((DEPLOYED + 1))
}

echo -e "${CYAN}[*] 部署到: $CLAUDE_DIR${NC}"
deploy "$CLAUDE_DIR" "终端版"

echo ""
echo -e "${CYAN}============================================${NC}"
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}  部署完成，但有 $ERRORS 个错误${NC}"
else
    echo -e "${GREEN}  部署完成!${NC}"
fi
echo -e "${CYAN}============================================${NC}"
echo ""
echo -e "${CYAN}  使用方法:${NC}"
echo -e "${CYAN}    打开终端输入 claude${NC}"
echo -e "${CYAN}    测试: 输入 在吗 看看效果${NC}"
echo ""
