# 🌐 单 Gateway 多 Agent 配置与管理

> **难度**: ⭐⭐⭐ 进阶 | **预计阅读**: 4 分钟

---

## 📋 本章要点

- 单 Gateway 可运行多个 Agent，每个拥有独立身份、记忆、技能和配置
- Agent 目录位于 `~/.openclaw/agents/<name>/workspace/`，含 IDENTITY.md、SOUL.md 等
- 路由规则将不同渠道/关键词映射到不同 Agent 处理
- 不同 Agent 可使用不同 AI 模型（如 Claude vs GPT-4）
- Agent 间通过共享文件、消息转发、Cron 定时、API 直接调用四种方式协作
- 共享记忆存放在 `~/.openclaw/workspace/shared-memory/`
- 支持配置热加载（`openclaw gateway reload`），无需停机
- 资源限制包括 maxConcurrent、memoryLimit、timeout 等参数

## 🔑 核心知识

多 Agent 架构的核心是 Gateway 统一入口 + 多独立 Workspace。每个 Agent 在 `openclaw.json` 的 `agents` 字段中配置，关键参数包括 `workspace`（目录路径）、`channels`（绑定渠道）、`model`（AI 模型）和 `enabled`（启用状态）。路由规则按正则模式匹配请求内容，依次匹配，首条命中生效，`default` 作为兜底。

Agent 间协作最常用的方式是共享文件目录——Agent 1 写入报告到 `shared-memory/`，Agent 2 的 Cron 任务定期读取并分析。更实时的协作可用消息转发，Gateway 根据路由规则将请求从一个 Agent 转发到另一个。配置修改后执行 `openclaw gateway reload` 可热加载，Workspace 文件变更则在下一次请求时自动读取。

## 💻 关键命令/代码

```bash
# 创建新 Agent workspace
mkdir -p ~/.openclaw/agents/agent-2/workspace/{memory,skills,config}

# 查看 Agent 列表和路由
openclaw agents list
openclaw agents routes

# 热加载配置
openclaw gateway reload
```

## 🔗 相关章节

- [[02 部署与环境初始化]] — Gateway 基础部署
- [[07 飞书集成与消息自动化]] — 消息通道配置
- [[09 故障排查与日志分析]] — 多 Agent 问题排查

---

> 📖 [阅读完整章节](https://github.com/zxk-git/openclaw-tutorial-auto/blob/main/08-单%20Gateway%20多%20Agent%20配置与管理.md)
