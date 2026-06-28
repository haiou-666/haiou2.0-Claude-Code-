# 贡献指南

感谢您对 Seagull 项目的关注！

## 如何贡献

### 报告问题

1. 使用 Issue 模板报告 bug
2. 提供详细的复现步骤
3. 包含系统信息（Windows 版本、PowerShell 版本）

### 提交代码

1. Fork 项目
2. 创建功能分支：`git checkout -b feature/xxx`
3. 提交更改：`git commit -m 'Add xxx'`
4. 推送分支：`git push origin feature/xxx`
5. 创建 Pull Request

### 改进文档

- 修复错别字
- 添加使用示例
- 翻译文档

## 开发规范

### 代码风格

- PowerShell：使用 PascalCase 命名函数
- 批处理：使用简洁的注释
- Markdown：使用标准语法

### 提交信息

- 使用中文或英文
- 简洁描述更改内容
- 关联 Issue 编号

### 测试

- 运行 `验证.bat` 确保配置正确
- 在不同 Windows 版本测试
- 验证中文显示正常

## 发布流程

1. 更新 VERSION 文件
2. 更新 CHANGELOG.md
3. 创建 Git tag
4. 打包发布

## 行为准则

- 尊重他人
- 保持专业
- 欢迎新手

## 联系方式

- Issue：GitHub Issues
- 讨论：GitHub Discussions

## 许可证

MIT License
