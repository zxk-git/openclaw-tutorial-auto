# 📥 Skills 安装与管理实践

> **难度**: ⭐⭐ 中级 | **预计阅读**: 3 分钟

---

## 📋 本章要点

- 四种安装方式：ClawdHub（推荐）、npx skills CLI、手动 Git Clone、MCP 工具集成
- ClawdHub 提供经官方审核的 Skills，一条命令即可安装
- Skills 遵循语义化版本管理（SemVer），支持更新、回退
- 安装前应通过 `skill-vetter` 进行安全审查（来源、代码、权限、红旗检测）
- 部分 Skills 需要在 `openclaw.json` 中配置 API Key（如 Tavily）
- MCP 型 Skill 通过 McPorter 管理，适合集成已有 REST API
- 执行审批机制（`exec-approvals.json`）可限制危险命令的自动执行

## 🔑 核心知识

ClawdHub（skills.sh）是 OpenClaw 官方技能市场，安装只需 `clawdhub install <name>` 或 `npx skills add <name>`。安装后 Skill 自动放入 `~/.openclaw/workspace/skills/` 目录并注册到系统。需要 API Key 的 Skills（如 tavily-search 需要 `TAVILY_API_KEY`）须在配置文件或环境变量中设置。

安全是 Skills 管理的重点。OpenClaw 内置 `skill-vetter` 技能，可对第三方 Skill 做来源检查、代码审查（扫描 `rm -rf`、`eval`、网络外泄等危险模式）和权限范围评估。最佳实践是优先使用 ClawdHub 官方审核的 Skills，在生产环境严格限制 `autoApprove` 列表，并定期运行 `npx skills check` 检查安全更新。

## 💻 关键命令/代码

```bash
# 从 ClawdHub 安装技能
clawdhub install tavily-search

# 搜索、检查更新、批量更新
npx skills find "web search"
npx skills check
npx skills update

# MCP 工具集成
mcporter config add exa https://mcp.exa.ai/mcp
```

## 🔗 相关章节

- [[03 Skills 插件体系与批量开发]] — Skill 开发基础
- [[05 ClawHub 平台与技能分发]] — 发布到 ClawHub
- [[11 高级场景 第三方平台集成]] — 第三方集成实践

---

> 📖 [阅读完整章节](https://github.com/zxk-git/openclaw-tutorial-auto/blob/main/04-Skills%20安装与管理实践.md)
