#!/bin/bash
# Mac一键修复+启动
# 双击此文件即可运行

# 去掉隔离标记
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
xattr -cr "$SCRIPT_DIR" 2>/dev/null

# 给所有sh和command文件加执行权限
chmod +x "$SCRIPT_DIR"/启动.command 2>/dev/null
chmod +x "$SCRIPT_DIR"/卸载.command 2>/dev/null
chmod +x "$SCRIPT_DIR"/seagull-files/install.sh 2>/dev/null
chmod +x "$SCRIPT_DIR"/scripts/*.sh 2>/dev/null

# 运行部署
bash "$SCRIPT_DIR/seagull-files/install.sh"
