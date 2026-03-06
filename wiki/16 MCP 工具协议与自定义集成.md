# 🔌 MCP 工具协议与自定义集成

> **难度**: ⭐⭐⭐⭐ 高级 | **预计阅读**: 28 分钟

---

## 📋 本章要点

- MCP（Model Context Protocol）是 Anthropic 提出的开放标准，为 AI Agent 提供统一的外部工具交互接口
- 核心理念：让 Agent 像使用 USB 设备一样**即插即用**地调用外部能力
- 采用 JSON-RPC 2.0 协议，支持 stdio / HTTP / SSE 三种传输方式
- 与 Function Calling 的区别：MCP 支持运行时动态发现、跨语言、内置权限控制
- `mcporter.json` 是 MCP 工具注册中心，配置所有 MCP Server 的连接方式
- 内置支持 GitHub、文件系统、Exa 搜索、SQLite、Puppeteer 等 MCP Server
- 可用 Node.js SDK 或 Python SDK 开发自定义 MCP Server
- 提供完整的调试命令、日志分析和自动化测试策略

## 🔑 核心知识

MCP 解决了 AI Agent 调用外部工具时的四大痛点：适配成本高、协议碎片化、安全难管控、能力不透明。通过统一的"工具描述 → 发现 → 调用 → 响应"流程，Agent 启动时自动连接配置的 MCP Server，调用 `tools/list` 获取可用工具清单，在推理过程中自主决定使用哪个工具。

选择集成方式的经验法则：一次性任务用 REST API + Skill 脚本；反复使用且仅限 OpenClaw 内部的用 Skill；需要跨平台共享或 Agent 自主决策的用 MCP Server。如果多个 Skill 重复调用同一 API，就应将其抽象为 MCP Server。MCP 生态丰富，官方和社区提供了覆盖 GitHub、数据库、搜索引擎、浏览器等场景的现成 Server。

## 💻 关键命令/代码

```bash
# 查看 MCP 配置
cat ~/.openclaw/workspace/config/mcporter.json

# mcporter.json 核心结构
# { "mcpServers": { "github": { "baseUrl": "https://api.githubcopilot.com/mcp" } } }

# MCP 通信流程：Agent → MCP Client → tools/list → tools/call → 返回结果
```

## 🔗 相关章节

- [[15 Memory 记忆系统深入]] | [[17 浏览器自动化与网页交互]]

---

> 📖 [阅读完整章节](https://github.com/zxk-git/openclaw-tutorial-auto/blob/main/16-MCP%20工具协议与自定义集成.md)
