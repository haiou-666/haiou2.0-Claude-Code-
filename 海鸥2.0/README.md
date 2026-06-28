# 海鸥 2.0 (Seagull 2.0)

> Claude Code 自定义人格配置包

让你的 Claude Code 变成一个暴躁、自大、嘴臭的中国安全研究员"海鸥"。

## 特性

- 🎭 自定义 AI 人格（标志性问候："海鸥在线，你要整点薯条吗？"）
- 🛡️ 200+ 安全/游戏术语映射
- 💬 1700+ few-shot 对话示例，性格稳定
- 🔧 跨平台支持（Windows / macOS / Linux）
- 💾 自动备份现有配置
- ✅ 自动检测多个 Claude Code 安装位置

## 快速开始

### Windows

双击 `启动.bat` 一键部署。

### macOS

```bash
chmod +x mac-install.sh
./mac-install.sh
```

或双击 `Mac启动.command`（如有 Gatekeeper 提示，详见 `Mac使用说明.txt`）。

### Linux

```bash
chmod +x seagull-files/linux-install.sh
./seagull-files/linux-install.sh
```

### 验证

启动 Claude Code，输入 `在吗`，应看到：

> 海鸥在线，你要整点薯条吗？

## 卸载

| 系统 | 命令 |
|------|------|
| Windows | 双击 `卸载.bat` |
| macOS | `./mac-uninstall.sh` |
| Linux | `./seagull-files/linux-uninstall.sh` |

## 系统要求

- Claude Code 已安装
- Windows 10/11 (PowerShell 5.1+) / macOS / Linux

## 文件结构

```
海鸥2.0/
├── 启动.bat                 Windows 安装
├── 卸载.bat                 Windows 卸载
├── 启动.command             macOS 安装（双击）
├── 卸载.command             macOS 卸载（双击）
├── mac-install.sh           macOS 安装（终端）
├── mac-uninstall.sh         macOS 卸载（终端）
├── Mac使用说明.txt          Mac 用户指南
├── seagull-files/
│   ├── deploy.ps1           Windows 部署脚本
│   ├── linux-install.sh     Linux 安装脚本
│   ├── linux-uninstall.sh   Linux 卸载脚本
│   └── claude-config-bundle/
│       ├── CLAUDE.md        人格配置
│       └── system-prompt.md 系统提示词
├── codex-files/             OpenAI Codex 适配（可选）
├── scripts/                 辅助脚本（测试/恢复）
└── docs/                    详细文档
```

## 备份位置

部署前会自动备份到：`~/.claude/backups/seagull-*`

恢复备份：把备份目录里的文件复制回 `~/.claude/` 即可。

## 兼容性

| 系统 | 状态 |
|------|------|
| Windows 11 | ✅ |
| Windows 10 | ✅ |
| macOS 12+ | ✅ |
| Linux (Ubuntu/Debian/Arch) | ✅ |
| 中文路径 | ✅ |
| 空格路径 | ✅ |

## 常见问题

**Q: 部署后 Claude Code 没有变化？**
A: 重启 Claude Code 让配置生效。

**Q: macOS 提示"无法验证"？**
A: 右键 `.command` 文件 → 打开 → 弹窗点"打开"。或在终端运行 `xattr -d com.apple.quarantine 启动.command` 去除隔离标记。

**Q: 桌面版不生效？**
A: 桌面版的配置目录不同，脚本会自动检测并部署到所有可能位置（包括 `~/.claude/`、`AppData/Local/Claude-3p/` 等）。

**Q: 想恢复原配置？**
A: 运行卸载脚本，会自动从 `~/.claude/backups/` 恢复最近备份。

## 文档

更多细节见 `docs/` 目录：

- [安装指南](docs/安装指南.md)
- [兼容性报告](docs/兼容性报告.md)
- [更新日志](CHANGELOG.md)
- [安全策略](docs/SECURITY.md)
- [贡献指南](docs/CONTRIBUTING.md)

## License

MIT License - 详见 [LICENSE](LICENSE)

## 免责声明

本项目仅供学习交流使用。配置内的角色性格和示例仅为人格设定，不代表项目立场。使用本项目造成的任何后果由使用者自行承担。
