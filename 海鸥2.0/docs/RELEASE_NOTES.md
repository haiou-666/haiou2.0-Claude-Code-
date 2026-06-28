# Seagull v18.1 发布说明

## 发布日期

2026-06-18

## 新增功能

### 环境检测
- 自动检测 PowerShell 版本
- 自动检测 Windows 版本
- 显示用户信息和目标路径

### 备份管理
- 自动备份现有配置
- 支持恢复最近备份
- 备份目录：`%USERPROFILE%\.claude\backups\seagull-*`

### 部署验证
- 检查所有文件是否存在
- 验证问候语配置
- 验证权限配置
- 验证 config.toml 指向

### 命令行支持
- `-Uninstall`：卸载模式
- `-Verify`：验证模式
- `-Restore`：恢复模式

### 文档完善
- README.md：项目概述
- 安装指南.md：详细安装步骤
- CHANGELOG.md：版本记录
- CONTRIBUTING.md：贡献指南
- SECURITY.md：安全政策
- CODE_OF_CONDUCT.md：行为准则
- SUPPORT.md：支持信息

## 文件结构

```
打开c语言/
├── 启动.bat (一键部署)
├── 卸载.bat (一键卸载)
├── 验证.bat (验证部署)
├── 恢复备份.bat (恢复备份)
├── 快速测试.bat (快速测试)
├── README.md
├── 安装指南.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
├── CODE_OF_CONDUCT.md
├── SUPPORT.md
├── LICENSE
├── VERSION
├── .gitignore
└── seagull-files/
    ├── deploy.ps1 (v18.1)
    └── claude-config-bundle/
        ├── CLAUDE.md (2000+ few-shot 示例)
        └── system-prompt.md (200+ 术语)
```

## 系统要求

- Windows 10/11
- PowerShell 5.1+
- Claude Code 已安装

## 安装

1. 下载 `打开c语言.zip`
2. 解压到任意位置
3. 双击 `启动.bat`
4. 重启 Claude Code
5. 输入 `在吗` 测试

## 卸载

双击 `卸载.bat` 或运行：
```powershell
.\seagull-files\deploy.ps1 -Uninstall
```

## 已知问题

- 中文路径可能导致 PowerShell 编码问题（已通过 bat 文件修复）
- 某些 Windows 版本可能需要管理员权限

## 下一步计划

- 支持 macOS/Linux
- 支持更多 Claude Code 版本
- 支持自定义问候语
- 支持自定义性格

## 反馈

欢迎在 GitHub Issues 中反馈问题和建议！

## 许可证

MIT License
