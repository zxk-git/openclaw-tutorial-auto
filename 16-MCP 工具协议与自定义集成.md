---
[⬅️ 上一章：Memory 记忆系统深入](15-Memory%20记忆系统深入.md) | [📑 目录](README.md) | [➡️ 下一章：浏览器自动化与网页交互](17-浏览器自动化与网页交互.md)
---

# 第16章：MCP 工具协议与自定义集成

> **难度**: ⭐⭐⭐⭐ 高级 | **预计阅读**: 28 分钟 | **前置章节**: [第 3 章](03-Skills%20插件体系与批量开发.md)、[第 11 章](11-高级场景-第三方平台集成.md)

> MCP（Model Context Protocol）是 AI Agent 与外部工具交互的标准化协议。本章将从协议规范讲起，深入讲解 MCP 的设计哲学、内置工具的使用、自定义 MCP Server 的开发流程，以及调试、测试和生态资源。掌握 MCP 是构建强大 Agent 集成能力的关键。

## 📑 本章目录

- [16.1 MCP 概述与规范](#161-mcp-概述与规范)
  - [16.1.1 什么是 MCP](#1611-什么是-mcp)
  - [16.1.2 MCP 解决的核心问题](#1612-mcp-解决的核心问题)
  - [16.1.3 MCP 协议架构](#1613-mcp-协议架构)
  - [16.1.4 MCP 与 Function Calling 的对比](#1614-mcp-与-function-calling-的对比)
- [16.2 MCP 与传统 API 的区别](#162-mcp-与传统-api-的区别)
  - [16.2.1 三种集成方式对比](#1621-三种集成方式对比)
  - [16.2.2 选择指南](#1622-选择指南)
- [16.3 使用内置 MCP 工具](#163-使用内置-mcp-工具)
  - [16.3.1 mcporter.json 配置详解](#1631-mcporterjson-配置详解)
  - [16.3.2 内置 MCP Server 一览](#1632-内置-mcp-server-一览)
  - [16.3.3 GitHub MCP 使用示例](#1633-github-mcp-使用示例)
  - [16.3.4 文件系统 MCP 使用示例](#1634-文件系统-mcp-使用示例)
  - [16.3.5 搜索 MCP 使用示例](#1635-搜索-mcp-使用示例)
- [16.4 开发自定义 MCP Server](#164-开发自定义-mcp-server)
  - [16.4.1 Node.js SDK 开发](#1641-nodejs-sdk-开发)
  - [16.4.2 Python SDK 开发](#1642-python-sdk-开发)
  - [16.4.3 工具定义规范](#1643-工具定义规范)
  - [16.4.4 资源与 Prompt 定义](#1644-资源与-prompt-定义)
- [16.5 MCP Server 注册与配置](#165-mcp-server-注册与配置)
  - [16.5.1 mcporter.json 完整参考](#1651-mcporterjson-完整参考)
  - [16.5.2 传输方式选择](#1652-传输方式选择)
  - [16.5.3 环境变量与安全配置](#1653-环境变量与安全配置)
- [16.6 MCP 工具调试与测试](#166-mcp-工具调试与测试)
  - [16.6.1 调试命令](#1661-调试命令)
  - [16.6.2 日志分析](#1662-日志分析)
  - [16.6.3 自动化测试策略](#1663-自动化测试策略)
- [16.7 MCP 生态：社区工具与推荐](#167-mcp-生态社区工具与推荐)
  - [16.7.1 官方 MCP Server 列表](#1671-官方-mcp-server-列表)
  - [16.7.2 社区精选工具](#1672-社区精选工具)
  - [16.7.3 MCP 工具发现与安装](#1673-mcp-工具发现与安装)
- [实操练习](#实操练习)
- [常见问题 (FAQ)](#常见问题-faq)
- [本章小结](#本章小结)

---

## 16.1 MCP 概述与规范

### 16.1.1 什么是 MCP

MCP（Model Context Protocol，模型上下文协议）是由 Anthropic 提出的开放标准协议，旨在为 AI 模型提供与外部工具、数据源和服务交互的统一接口。MCP 的核心理念是**让 AI Agent 像使用 USB 设备一样即插即用地调用外部能力**。

MCP 的设计遵循以下原则：

- **标准化**：统一的 JSON-RPC 2.0 通信协议，任何语言都能实现
- **安全性**：内置权限控制和审批机制，防止工具滥用
- **可发现性**：AI 可以动态发现可用工具，自主决定何时使用
- **可组合性**：多个 MCP Server 可以并行使用，能力互相叠加

```text
传统模式：                    MCP 模式：

Agent ──→ API 1 (REST)      Agent ──→ MCP Client ──→ MCP Server A
Agent ──→ API 2 (GraphQL)                        ──→ MCP Server B
Agent ──→ API 3 (SDK)                            ──→ MCP Server C
Agent ──→ API 4 (CLI)                            ──→ ...

每个都要单独适配                统一协议，即插即用
```

### 16.1.2 MCP 解决的核心问题

在没有 MCP 之前，AI Agent 调用外部工具面临以下困境：

1. **适配成本高**：每接入一个新服务，需要编写独立的适配层代码
2. **协议碎片化**：REST、GraphQL、gRPC、CLI 各有各的调用方式
3. **安全难管控**：工具调用的权限控制和审计缺少统一方案
4. **能力不透明**：Agent 无法自动发现有哪些工具可用

MCP 通过引入统一的**工具描述 → 发现 → 调用 → 响应**流程，一次性解决了这些问题。

> [!NOTE]
> MCP 不是要取代 REST API，而是在 AI Agent 和外部服务之间增加一层标准化的"翻译层"。已有的 REST API 可以通过编写 MCP Server 包装后暴露给 Agent 使用。

### 16.1.3 MCP 协议架构

MCP 采用经典的 Client-Server 架构，在 OpenClaw 中的交互流程如下：

```text
┌────────────────────────────────────────────────────────────┐
│                    OpenClaw Agent                           │
│                                                            │
│   ┌──────────────────────────────────────────────────┐    │
│   │                MCP Client (内置)                   │    │
│   │                                                    │    │
│   │  ┌─────────┐  ┌──────────┐  ┌──────────────┐    │    │
│   │  │ 工具发现 │  │ 请求构建  │  │  响应解析     │    │    │
│   │  │ listTools│  │ callTool │  │  parseResult  │    │    │
│   │  └────┬────┘  └────┬─────┘  └──────┬───────┘    │    │
│   │       │             │               │             │    │
│   └───────┼─────────────┼───────────────┼─────────────┘    │
│           │             │               │                   │
└───────────┼─────────────┼───────────────┼───────────────────┘
            │             │               │
            │  JSON-RPC 2.0 over stdio/HTTP/SSE
            │             │               │
┌───────────┼─────────────┼───────────────┼───────────────────┐
│           ▼             ▼               ▲                   │
│   ┌─────────────────────────────────────────┐              │
│   │             MCP Server                    │              │
│   │                                           │              │
│   │  ┌──────────┐ ┌──────────┐ ┌─────────┐  │              │
│   │  │ 工具注册  │ │ 请求处理  │ │ 权限校验 │  │              │
│   │  │ register │ │ handler  │ │ auth    │  │              │
│   │  └──────────┘ └──────────┘ └─────────┘  │              │
│   └──────────────────┬──────────────────────┘              │
│                      │                                      │
│              ┌───────▼────────┐                             │
│              │  外部服务/数据源 │                             │
│              │  Database/API   │                             │
│              └────────────────┘                             │
│                                                             │
│                MCP Server 进程                               │
└─────────────────────────────────────────────────────────────┘
```

**通信流程**：

1. **初始化阶段**：Agent 启动时，MCP Client 连接所有配置的 MCP Server
2. **工具发现**：Client 调用 `tools/list` 获取每个 Server 提供的工具清单
3. **工具调用**：Agent 推理过程中决定使用某个工具，Client 发送 `tools/call` 请求
4. **结果返回**：Server 执行工具逻辑并返回结果，Agent 继续推理

### 16.1.4 MCP 与 Function Calling 的对比

| 维度 | Function Calling | MCP |
|------|-----------------|-----|
| 定义位置 | 嵌入在 Prompt/API 请求中 | 独立的 Server 进程 |
| 执行方式 | 应用层代码执行 | Server 端执行 |
| 动态发现 | ❌ 需要预定义 | ✅ 运行时动态发现 |
| 跨语言支持 | 取决于应用实现 | ✅ 任何语言的 Server |
| 权限控制 | 应用层自行实现 | ✅ 协议内置审批机制 |
| 状态管理 | 无状态（每次传入） | ✅ Server 可维护状态 |
| 可复用性 | 低（绑定特定应用） | ✅ 高（一次开发，多处使用） |
| 生态系统 | 无 | ✅ 丰富的社区工具 |

> [!TIP]
> 简单理解：Function Calling 是"告诉 AI 有哪些函数可以调用"，MCP 是"给 AI 一个工具箱，它自己打开看里面有什么"。两者并不冲突，MCP 工具最终也是以类似 Function Calling 的方式呈现给模型的。

---

## 16.2 MCP 与传统 API 的区别

### 16.2.1 三种集成方式对比

在 OpenClaw 中，Agent 与外部能力集成有三种主要途径：

| 对比维度 | REST API（直接调用） | Skill（技能插件） | MCP Server |
|---------|---------------------|-------------------|------------|
| **开发成本** | 低（直接 curl） | 中（编写 Skill 配置） | 中（编写 MCP Server） |
| **复用性** | 低（硬编码在脚本中） | 中（可分享到 ClawHub） | 高（标准协议，通用） |
| **AI 友好度** | 低（需明确指定调用） | 中（通过触发词激活） | 高（AI 自动发现和选择） |
| **权限管理** | 手动管理 Token | Skill 级别的执行审批 | 内置审批机制 |
| **状态管理** | 无 | 有（通过 memory） | 有（Server 端维护） |
| **适用场景** | 一次性脚本 | 重复性自动化任务 | 通用工具能力扩展 |
| **协议标准** | 各异 | OpenClaw 私有 | 开放标准 |

### 16.2.2 选择指南

```text
需要给 Agent 添加外部能力？
│
├── 是一次性任务？────→ 直接在 Skill 脚本中调用 REST API
│
├── 需要反复使用？
│   ├── 只在 OpenClaw 内使用？────→ 开发 Skill
│   └── 希望跨平台共享？──────────→ 开发 MCP Server
│
└── 需要 Agent 自主决策何时使用？──→ 开发 MCP Server
```

> [!TIP]
> 经验法则：如果你发现自己在多个 Skill 中重复调用同一个 API，说明应该将其抽象为 MCP Server。如果工具只在一个特定的自动化流程中使用，Skill 就够了。

---

## 16.3 使用内置 MCP 工具

OpenClaw 开箱支持多种 MCP Server。通过 `mcporter.json` 配置文件，可以快速启用内置工具能力。

### 16.3.1 mcporter.json 配置详解

MCP 工具的注册中心是 `~/.openclaw/workspace/config/mcporter.json`。基本结构如下：

```json
{
  "mcpServers": {
    "server-name": {
      "baseUrl": "http://localhost:PORT/mcp",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-name"],
      "env": {
        "API_KEY": "your-api-key"
      },
      "timeout": 30000,
      "enabled": true
    }
  },
  "imports": []
}
```

**字段说明**：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `baseUrl` | string | 与 command 二选一 | HTTP/SSE 方式连接的 MCP Server URL |
| `command` | string | 与 baseUrl 二选一 | stdio 方式启动 MCP Server 的命令 |
| `args` | string[] | 否 | 命令参数 |
| `env` | object | 否 | 环境变量（API Key 等敏感信息） |
| `timeout` | number | 否 | 工具调用超时时间（毫秒），默认 30000 |
| `enabled` | boolean | 否 | 是否启用，默认 true |

### 16.3.2 内置 MCP Server 一览

OpenClaw 社区和官方维护的常用 MCP Server：

| MCP Server | 功能 | 连接方式 | 配置示例 |
|-----------|------|---------|---------|
| `github` | GitHub 仓库操作 | HTTP | `"baseUrl": "https://api.githubcopilot.com/mcp"` |
| `filesystem` | 本地文件读写 | stdio | `"command": "npx @modelcontextprotocol/server-filesystem"` |
| `exa` | AI 语义搜索 | HTTP | `"baseUrl": "https://mcp.exa.ai/mcp"` |
| `xiaohongshu-mcp` | 小红书数据接口 | HTTP | `"baseUrl": "http://localhost:18060/mcp"` |
| `sqlite` | SQLite 数据库操作 | stdio | `"command": "npx @modelcontextprotocol/server-sqlite"` |
| `brave-search` | Brave 搜索引擎 | stdio | `"command": "npx @modelcontextprotocol/server-brave-search"` |
| `puppeteer` | 浏览器自动化 | stdio | `"command": "npx @modelcontextprotocol/server-puppeteer"` |

### 16.3.3 GitHub MCP 使用示例

GitHub MCP 允许 Agent 直接操作 GitHub 仓库——创建 Issue、提交 PR、搜索代码等。

**配置**：

```json
{
  "mcpServers": {
    "github": {
      "baseUrl": "https://api.githubcopilot.com/mcp",
      "env": {
        "GITHUB_TOKEN": "ghp_xxxx..."
      }
    }
  }
}
```

**Agent 可使用的工具**（部分）：

```text
mcp_github_create_pull_request     — 创建 Pull Request
mcp_github_list_issues             — 列出 Issue 列表
mcp_github_search_code             — 搜索仓库代码
mcp_github_get_file_contents       — 获取文件内容
mcp_github_push_files              — 推送文件变更
mcp_github_create_branch           — 创建分支
mcp_github_add_issue_comment       — 为 Issue 添加评论
mcp_github_merge_pull_request      — 合并 Pull Request
```

**实际对话示例**：

```text
用户：帮我在 openclaw-tutorial-auto 仓库创建一个 Issue，
      标题是"补充 MCP 章节示例代码"，标签设为 enhancement。

Agent（内部推理）：
  → 调用 mcp_github_create_issue
  → 参数: repo="zxk/openclaw-tutorial-auto", title="补充 MCP 章节示例代码",
          labels=["enhancement"]
  → 返回: Issue #42 已创建

Agent 回复：已在「openclaw-tutorial-auto」仓库创建 Issue #42：
  "补充 MCP 章节示例代码"，标签为 enhancement。
```

### 16.3.4 文件系统 MCP 使用示例

文件系统 MCP 让 Agent 能够直接读写本地文件：

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/user/documents",
        "/home/user/projects"
      ]
    }
  }
}
```

> [!WARNING]
> 文件系统 MCP 仅允许访问 `args` 中指定的目录。不要将 `/` 或 `~` 添加为允许目录，这会给 Agent 过大的文件系统权限。始终遵循最小权限原则。

**Agent 可使用的工具**：

| 工具 | 说明 |
|------|------|
| `read_file` | 读取指定路径文件内容 |
| `write_file` | 创建/覆写文件 |
| `list_directory` | 列出目录内容 |
| `create_directory` | 创建目录 |
| `move_file` | 移动或重命名文件 |
| `search_files` | 按名称模式搜索文件 |
| `get_file_info` | 获取文件元信息（大小、修改时间等） |

### 16.3.5 搜索 MCP 使用示例

Exa 是一个 AI 语义搜索引擎，通过 MCP 集成后，Agent 可以进行高质量的网络搜索：

```json
{
  "mcpServers": {
    "exa": {
      "baseUrl": "https://mcp.exa.ai/mcp",
      "env": {
        "EXA_API_KEY": "exa-xxxx..."
      }
    }
  }
}
```

**搜索示例**：

```text
用户：搜索 OpenClaw 最新的社区动态。

Agent（内部推理）：
  → 调用 exa_search
  → 参数: query="OpenClaw AI agent 最新动态 2026", numResults=5
  → 返回: [5 条搜索结果]

Agent 回复：以下是 OpenClaw 最新的社区动态：
  1. [标题] — URL — 摘要
  2. ...
```

---

## 16.4 开发自定义 MCP Server

当内置工具无法满足需求时，你可以开发自定义 MCP Server。以下分别用 Node.js 和 Python 演示。

### 16.4.1 Node.js SDK 开发

**目标**：创建一个天气查询 MCP Server，提供 `get_weather` 和 `get_forecast` 两个工具。

**1. 初始化项目**：

```bash
mkdir mcp-weather-server && cd mcp-weather-server
npm init -y
npm install @modelcontextprotocol/sdk zod
```

**2. 编写 Server 代码**：

```javascript
// index.js
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

// 创建 MCP Server 实例
const server = new McpServer({
  name: "weather-server",
  version: "1.0.0",
  description: "提供天气查询能力的 MCP Server",
});

// 定义工具：获取当前天气
server.tool(
  "get_weather",
  "获取指定城市的当前天气信息",
  {
    city: z.string().describe("城市名称，如 '北京'、'上海'"),
    unit: z
      .enum(["celsius", "fahrenheit"])
      .optional()
      .default("celsius")
      .describe("温度单位"),
  },
  async ({ city, unit }) => {
    // 实际项目中，这里应调用真实的天气 API
    // 此处用模拟数据做演示
    const apiKey = process.env.WEATHER_API_KEY;
    const response = await fetch(
      `https://api.weatherapi.com/v1/current.json?key=${apiKey}&q=${encodeURIComponent(city)}&lang=zh`
    );

    if (!response.ok) {
      return {
        content: [
          {
            type: "text",
            text: `查询失败：无法获取 ${city} 的天气信息（HTTP ${response.status}）`,
          },
        ],
        isError: true,
      };
    }

    const data = await response.json();
    const temp =
      unit === "fahrenheit" ? data.current.temp_f : data.current.temp_c;
    const unitLabel = unit === "fahrenheit" ? "°F" : "°C";

    return {
      content: [
        {
          type: "text",
          text: [
            `📍 ${data.location.name}（${data.location.country}）`,
            `🌡️ 温度：${temp}${unitLabel}`,
            `🌤️ 天气：${data.current.condition.text}`,
            `💨 风速：${data.current.wind_kph} km/h`,
            `💧 湿度：${data.current.humidity}%`,
            `🕐 更新时间：${data.current.last_updated}`,
          ].join("\n"),
        },
      ],
    };
  }
);

// 定义工具：获取天气预报
server.tool(
  "get_forecast",
  "获取指定城市未来几天的天气预报",
  {
    city: z.string().describe("城市名称"),
    days: z
      .number()
      .min(1)
      .max(7)
      .default(3)
      .describe("预报天数，1-7 天"),
  },
  async ({ city, days }) => {
    const apiKey = process.env.WEATHER_API_KEY;
    const response = await fetch(
      `https://api.weatherapi.com/v1/forecast.json?key=${apiKey}&q=${encodeURIComponent(city)}&days=${days}&lang=zh`
    );

    if (!response.ok) {
      return {
        content: [{ type: "text", text: `查询失败（HTTP ${response.status}）` }],
        isError: true,
      };
    }

    const data = await response.json();
    const forecastLines = data.forecast.forecastday.map((day) => {
      return `📅 ${day.date} | ${day.day.condition.text} | ${day.day.mintemp_c}°C ~ ${day.day.maxtemp_c}°C | 降雨概率 ${day.day.daily_chance_of_rain}%`;
    });

    return {
      content: [
        {
          type: "text",
          text: `📍 ${data.location.name} 未来 ${days} 天天气预报：\n\n${forecastLines.join("\n")}`,
        },
      ],
    };
  }
);

// 启动 Server（使用 stdio 传输）
const transport = new StdioServerTransport();
await server.connect(transport);
console.error("Weather MCP Server 已启动（stdio 模式）");
```

**3. 配置 package.json**：

```json
{
  "name": "mcp-weather-server",
  "version": "1.0.0",
  "type": "module",
  "main": "index.js",
  "bin": {
    "mcp-weather-server": "./index.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.0.0",
    "zod": "^3.22.0"
  }
}
```

**4. 本地测试运行**：

```bash
# 设置 API Key
export WEATHER_API_KEY="your-api-key-here"

# 直接运行测试
node index.js

# 或使用 MCP Inspector 进行交互式调试
npx @modelcontextprotocol/inspector node index.js
```

### 16.4.2 Python SDK 开发

对于 Python 开发者，可以使用 `mcp` 官方 Python SDK：

**1. 初始化项目**：

```bash
mkdir mcp-weather-python && cd mcp-weather-python
pip install mcp httpx
```

**2. 编写 Server 代码**：

```python
# server.py
import httpx
import os
from mcp.server.fastmcp import FastMCP

# 创建 MCP Server
mcp = FastMCP(
    name="weather-server-py",
    version="1.0.0",
    description="天气查询 MCP Server（Python 版）"
)

WEATHER_API_KEY = os.environ.get("WEATHER_API_KEY", "")
BASE_URL = "https://api.weatherapi.com/v1"


@mcp.tool()
async def get_weather(city: str, unit: str = "celsius") -> str:
    """获取指定城市的当前天气信息。

    Args:
        city: 城市名称，如 '北京'、'上海'
        unit: 温度单位，celsius 或 fahrenheit
    """
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            f"{BASE_URL}/current.json",
            params={"key": WEATHER_API_KEY, "q": city, "lang": "zh"},
        )
        resp.raise_for_status()
        data = resp.json()

    current = data["current"]
    location = data["location"]
    temp = current["temp_f"] if unit == "fahrenheit" else current["temp_c"]
    unit_label = "°F" if unit == "fahrenheit" else "°C"

    return (
        f"📍 {location['name']}（{location['country']}）\n"
        f"🌡️ 温度：{temp}{unit_label}\n"
        f"🌤️ 天气：{current['condition']['text']}\n"
        f"💨 风速：{current['wind_kph']} km/h\n"
        f"💧 湿度：{current['humidity']}%\n"
        f"🕐 更新时间：{current['last_updated']}"
    )


@mcp.tool()
async def get_forecast(city: str, days: int = 3) -> str:
    """获取指定城市未来几天的天气预报。

    Args:
        city: 城市名称
        days: 预报天数，1-7 天
    """
    days = max(1, min(7, days))
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            f"{BASE_URL}/forecast.json",
            params={
                "key": WEATHER_API_KEY,
                "q": city,
                "days": days,
                "lang": "zh",
            },
        )
        resp.raise_for_status()
        data = resp.json()

    lines = []
    for day in data["forecast"]["forecastday"]:
        d = day["day"]
        lines.append(
            f"📅 {day['date']} | {d['condition']['text']} | "
            f"{d['mintemp_c']}°C ~ {d['maxtemp_c']}°C | "
            f"降雨概率 {d['daily_chance_of_rain']}%"
        )

    location = data["location"]["name"]
    return f"📍 {location} 未来 {days} 天天气预报：\n\n" + "\n".join(lines)


@mcp.resource("weather://current/{city}")
async def current_weather_resource(city: str) -> str:
    """将当前天气作为 MCP Resource 暴露。"""
    return await get_weather(city)


if __name__ == "__main__":
    mcp.run(transport="stdio")
```

**3. 运行测试**：

```bash
export WEATHER_API_KEY="your-api-key"
python server.py

# 或使用 MCP Inspector
npx @modelcontextprotocol/inspector python server.py
```

### 16.4.3 工具定义规范

每个 MCP 工具需要提供以下信息：

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 工具唯一标识，格式为 `snake_case` |
| `description` | string | 工具功能描述，AI 依据此说明判断何时调用 |
| `inputSchema` | JSON Schema | 参数定义，使用 JSON Schema 或 Zod Schema |

> [!WARNING]
> `description` 字段极其重要！AI 主要依靠工具描述来判断何时使用该工具。描述应当清晰、具体、包含典型用例。避免使用模糊的描述如"处理数据"，应改为"根据城市名称查询当前天气温度、湿度和风速信息"。

**好的工具描述示例**：

```javascript
// ✅ 好的描述
server.tool(
  "search_products",
  "在电商平台搜索商品。支持按名称、品类、价格区间筛选。返回商品列表包含名称、价格、销量和评分。",
  { /* schema */ },
  handler
);

// ❌ 差的描述
server.tool(
  "search",
  "搜索功能",
  { /* schema */ },
  handler
);
```

### 16.4.4 资源与 Prompt 定义

除了 Tool（工具），MCP 还支持两种额外的能力类型：

**Resource（资源）** — 向 AI 提供上下文数据：

```javascript
// Node.js 示例
server.resource(
  "config",                           // 资源名称
  "config://app/settings",            // 资源 URI
  "应用配置信息，包含版本号和功能开关", // 描述
  async () => ({
    contents: [{
      uri: "config://app/settings",
      mimeType: "application/json",
      text: JSON.stringify({
        version: "2.1.0",
        features: { darkMode: true, betaFeatures: false }
      })
    }]
  })
);
```

**Prompt（提示模板）** — 预定义的交互模板：

```javascript
server.prompt(
  "weather_report",
  "生成城市天气报告的提示模板",
  { city: z.string().describe("城市名称") },
  async ({ city }) => ({
    messages: [{
      role: "user",
      content: {
        type: "text",
        text: `请为 ${city} 编写一份详细的天气分析报告，包含当前天气、未来趋势和出行建议。`
      }
    }]
  })
);
```

---

## 16.5 MCP Server 注册与配置

### 16.5.1 mcporter.json 完整参考

开发完成后，将 MCP Server 注册到 OpenClaw：

```json
{
  "mcpServers": {
    "weather": {
      "command": "node",
      "args": ["/home/user/mcp-weather-server/index.js"],
      "env": {
        "WEATHER_API_KEY": "your-api-key"
      },
      "timeout": 15000,
      "enabled": true
    },
    "weather-py": {
      "command": "python",
      "args": ["/home/user/mcp-weather-python/server.py"],
      "env": {
        "WEATHER_API_KEY": "your-api-key"
      },
      "timeout": 15000,
      "enabled": true
    },
    "exa": {
      "baseUrl": "https://mcp.exa.ai/mcp",
      "env": {
        "EXA_API_KEY": "exa-xxxx"
      }
    },
    "github": {
      "baseUrl": "https://api.githubcopilot.com/mcp"
    }
  },
  "imports": [
    "https://registry.mcphub.io/popular-servers.json"
  ]
}
```

### 16.5.2 传输方式选择

MCP 支持两种传输方式：

| 传输方式 | 配置字段 | 特点 | 适用场景 |
|---------|---------|------|---------|
| **stdio** | `command` + `args` | Server 作为子进程启动，通过标准输入输出通信 | 本地部署、开发调试 |
| **HTTP/SSE** | `baseUrl` | 通过 HTTP 请求通信，支持 SSE 流式响应 | 远程服务、云部署、共享 Server |

**stdio 方式**（推荐用于本地开发）：

```json
{
  "weather": {
    "command": "node",
    "args": ["./mcp-weather-server/index.js"],
    "env": { "WEATHER_API_KEY": "xxx" }
  }
}
```

Agent 启动时自动启动 Server 子进程，通信延迟极低。

**HTTP/SSE 方式**（推荐用于远程服务）：

```json
{
  "weather": {
    "baseUrl": "http://my-server.example.com:8080/mcp"
  }
}
```

Server 独立部署运行，Agent 通过网络连接。

### 16.5.3 环境变量与安全配置

> [!WARNING]
> 绝对不要将 API Key 硬编码到代码中！使用 `env` 字段在 mcporter.json 中配置，或使用系统环境变量。

**安全最佳实践**：

```bash
# 方法 1：通过 mcporter.json 的 env 字段（推荐）
# 配置写在 mcporter.json 中，文件本身应设为 600 权限
chmod 600 ~/.openclaw/workspace/config/mcporter.json

# 方法 2：通过系统环境变量
export WEATHER_API_KEY="your-key"

# 方法 3：通过 .env 文件
echo "WEATHER_API_KEY=your-key" >> ~/.openclaw/.env
```

---

## 16.6 MCP 工具调试与测试

### 16.6.1 调试命令

OpenClaw 提供了丰富的 MCP 调试能力：

```bash
# 查看当前已注册的 MCP Server 及其状态
openclaw mcp list

# 输出示例：
# ┌──────────┬──────────┬──────────┬───────────────┐
# │ Server   │ Status   │ Tools    │ Transport     │
# ├──────────┼──────────┼──────────┼───────────────┤
# │ weather  │ ✅ Ready  │ 2        │ stdio         │
# │ exa      │ ✅ Ready  │ 3        │ HTTP/SSE      │
# │ github   │ ✅ Ready  │ 24       │ HTTP/SSE      │
# │ sqlite   │ ❌ Error  │ 0        │ stdio         │
# └──────────┴──────────┴──────────┴───────────────┘

# 查看指定 Server 的所有工具
openclaw mcp tools weather

# 输出示例：
# weather-server (v1.0.0):
#   - get_weather: 获取指定城市的当前天气信息
#     参数: city (string, required), unit (string, optional)
#   - get_forecast: 获取指定城市未来几天的天气预报
#     参数: city (string, required), days (number, optional)

# 手动调用 MCP 工具（无需通过 Agent）
openclaw mcp call weather get_weather '{"city": "北京"}'

# 重新加载 MCP 配置
openclaw mcp reload

# 查看 MCP Server 详细日志
openclaw mcp logs weather --tail 50
```

### 16.6.2 日志分析

MCP 通信日志存储在 `~/.openclaw/logs/` 目录：

```bash
# 查看 MCP 通信日志
tail -f ~/.openclaw/logs/mcp-*.log

# 日志格式示例：
# [2026-03-06T10:23:45Z] [mcp:weather] → tools/list
# [2026-03-06T10:23:45Z] [mcp:weather] ← tools: ["get_weather", "get_forecast"]
# [2026-03-06T10:24:12Z] [mcp:weather] → tools/call get_weather {"city":"北京"}
# [2026-03-06T10:24:13Z] [mcp:weather] ← result: {content: [{type: "text", ...}]}

# 过滤错误日志
grep -i "error\|fail\|timeout" ~/.openclaw/logs/mcp-weather.log

# 统计工具调用频率
grep "tools/call" ~/.openclaw/logs/mcp-*.log | \
  awk '{print $4}' | sort | uniq -c | sort -rn
```

> [!TIP]
> 使用 MCP Inspector 进行交互式调试是最高效的方式。它提供了一个网页界面，可以直接浏览工具列表、发送测试请求、查看响应：
> ```bash
> npx @modelcontextprotocol/inspector node ./mcp-weather-server/index.js
> # 打开浏览器访问 http://localhost:5173
> ```

### 16.6.3 自动化测试策略

为 MCP Server 编写自动化测试，确保工具的可靠性：

```javascript
// test/weather-server.test.js
import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

describe("Weather MCP Server", () => {
  let client;

  beforeAll(async () => {
    const transport = new StdioClientTransport({
      command: "node",
      args: ["./index.js"],
      env: { ...process.env, WEATHER_API_KEY: "test-key" },
    });
    client = new Client({ name: "test-client", version: "1.0.0" });
    await client.connect(transport);
  });

  afterAll(async () => {
    await client.close();
  });

  it("应列出所有工具", async () => {
    const result = await client.listTools();
    expect(result.tools).toHaveLength(2);
    expect(result.tools.map((t) => t.name)).toContain("get_weather");
    expect(result.tools.map((t) => t.name)).toContain("get_forecast");
  });

  it("get_weather 应返回天气信息", async () => {
    const result = await client.callTool({
      name: "get_weather",
      arguments: { city: "北京" },
    });
    expect(result.content[0].type).toBe("text");
    expect(result.content[0].text).toContain("温度");
    expect(result.isError).toBeFalsy();
  });

  it("无效城市应返回错误", async () => {
    const result = await client.callTool({
      name: "get_weather",
      arguments: { city: "不存在的城市xyz" },
    });
    expect(result.isError).toBe(true);
  });

  it("get_forecast 天数应在 1-7 之间", async () => {
    const result = await client.callTool({
      name: "get_forecast",
      arguments: { city: "上海", days: 5 },
    });
    expect(result.content[0].text).toContain("未来 5 天");
  });
});
```

运行测试：

```bash
npm install -D vitest
npx vitest run
```

---

## 16.7 MCP 生态：社区工具与推荐

### 16.7.1 官方 MCP Server 列表

Anthropic 官方维护的 MCP Server（`@modelcontextprotocol/server-*`）：

| Server | npm 包 | 功能 |
|--------|--------|------|
| Filesystem | `@modelcontextprotocol/server-filesystem` | 安全的本地文件系统读写 |
| GitHub | `@modelcontextprotocol/server-github` | GitHub API 操作 |
| GitLab | `@modelcontextprotocol/server-gitlab` | GitLab API 操作 |
| Brave Search | `@modelcontextprotocol/server-brave-search` | Brave 搜索引擎 |
| Google Maps | `@modelcontextprotocol/server-google-maps` | 地图与地理位置 |
| Puppeteer | `@modelcontextprotocol/server-puppeteer` | 浏览器自动化 |
| SQLite | `@modelcontextprotocol/server-sqlite` | SQLite 数据库操作 |
| Memory | `@modelcontextprotocol/server-memory` | 基于知识图谱的持久记忆 |
| Slack | `@modelcontextprotocol/server-slack` | Slack 消息与频道管理 |
| PostgreSQL | `@modelcontextprotocol/server-postgres` | PostgreSQL 数据库操作 |

### 16.7.2 社区精选工具

社区贡献的高质量 MCP Server：

| Server | 功能 | 语言 | 链接 |
|--------|------|------|------|
| `mcp-notion` | Notion 页面和数据库操作 | TypeScript | github.com/makenotion/notion-mcp-server |
| `mcp-linear` | Linear 项目管理 | TypeScript | github.com/linear/linear-mcp-server |
| `mcp-docker` | Docker 容器管理 | Python | github.com/ckreiling/mcp-server-docker |
| `mcp-kubernetes` | Kubernetes 集群管理 | Go | github.com/strowk/mcp-k8s-go |
| `mcp-obsidian` | Obsidian 知识库操作 | TypeScript | github.com/smithery-ai/mcp-obsidian |
| `mcp-youtube` | YouTube 视频信息获取 | Python | github.com/anaisbetts/mcp-youtube |
| `xiaohongshu-mcp` | 小红书数据接口 | Python | 自部署 |

### 16.7.3 MCP 工具发现与安装

```bash
# 搜索可用的 MCP Server
npx @anthropic-ai/mcp-registry search "weather"

# 一键安装并注册（未来生态支持）
openclaw mcp install @modelcontextprotocol/server-brave-search

# 手动安装：全局安装 npm 包
npm install -g @modelcontextprotocol/server-brave-search

# 然后在 mcporter.json 中注册
```

> [!NOTE]
> MCP 生态正在快速发展。截至 2026 年 3 月，已有超过 200 个社区贡献的 MCP Server。推荐关注 [MCP 官方仓库](https://github.com/modelcontextprotocol) 和 [Awesome MCP Servers](https://github.com/punkpeye/awesome-mcp-servers) 获取最新动态。

---

## 实操练习

### 🧪 练习 1：注册并使用内置 MCP 工具

**目标**：配置文件系统 MCP Server 并测试使用。

**步骤**：

1. 编辑 `~/.openclaw/workspace/config/mcporter.json`，添加 filesystem MCP：

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/tmp/mcp-test"
      ]
    }
  }
}
```

2. 创建测试目录和文件：

```bash
mkdir -p /tmp/mcp-test
echo "Hello from MCP!" > /tmp/mcp-test/hello.txt
```

3. 验证 MCP Server 状态：

```bash
openclaw mcp list
openclaw mcp tools filesystem
```

4. 通过 Agent 测试文件读取（在对话中输入）：

```text
请读取 /tmp/mcp-test/hello.txt 的内容
```

**验证要点**：Agent 应能成功读取文件内容并返回 "Hello from MCP!"。

---

### 🧪 练习 2：开发并注册自定义 MCP Server

**目标**：从零开发一个"待办事项"MCP Server 并注册到 OpenClaw。

**功能需求**：
- `add_todo`：添加待办事项
- `list_todos`：列出所有待办事项
- `complete_todo`：完成指定待办事项
- `delete_todo`：删除待办事项

**参考骨架代码**：

```javascript
// todo-mcp-server/index.js
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import fs from "fs/promises";

const server = new McpServer({
  name: "todo-server",
  version: "1.0.0",
});

const TODO_FILE = "/tmp/mcp-todos.json";

// 辅助函数：读取待办列表
async function loadTodos() {
  try {
    const data = await fs.readFile(TODO_FILE, "utf-8");
    return JSON.parse(data);
  } catch {
    return [];
  }
}

// 辅助函数：保存待办列表
async function saveTodos(todos) {
  await fs.writeFile(TODO_FILE, JSON.stringify(todos, null, 2));
}

server.tool(
  "add_todo",
  "添加一条新的待办事项",
  {
    title: z.string().describe("待办事项标题"),
    priority: z.enum(["low", "medium", "high"]).default("medium").describe("优先级"),
  },
  async ({ title, priority }) => {
    const todos = await loadTodos();
    const newTodo = {
      id: Date.now().toString(),
      title,
      priority,
      completed: false,
      createdAt: new Date().toISOString(),
    };
    todos.push(newTodo);
    await saveTodos(todos);
    return {
      content: [{ type: "text", text: `✅ 已添加待办：「${title}」（优先级：${priority}）` }],
    };
  }
);

server.tool(
  "list_todos",
  "列出所有待办事项，可按状态筛选",
  {
    status: z.enum(["all", "pending", "completed"]).default("all").describe("筛选状态"),
  },
  async ({ status }) => {
    let todos = await loadTodos();
    if (status === "pending") todos = todos.filter((t) => !t.completed);
    if (status === "completed") todos = todos.filter((t) => t.completed);

    if (todos.length === 0) {
      return { content: [{ type: "text", text: "📋 暂无待办事项" }] };
    }

    const lines = todos.map(
      (t) =>
        `${t.completed ? "✅" : "⬜"} [${t.priority}] ${t.title} (ID: ${t.id})`
    );
    return {
      content: [{ type: "text", text: `📋 待办列表：\n${lines.join("\n")}` }],
    };
  }
);

// TODO: 实现 complete_todo 和 delete_todo ...

const transport = new StdioServerTransport();
await server.connect(transport);
```

**操作步骤**：

1. 创建项目并安装依赖
2. 补全 `complete_todo` 和 `delete_todo` 工具
3. 在 `mcporter.json` 中注册
4. 通过 `openclaw mcp list` 验证
5. 与 Agent 对话测试全部 4 个工具

---

## 常见问题 (FAQ)

### Q1: MCP Server 启动失败怎么排查？

**A**: 按以下顺序排查：

```bash
# 1. 检查 Server 能否独立运行
node ./mcp-weather-server/index.js
# 如果报错，先修复 Server 代码

# 2. 检查 mcporter.json 配置格式
cat ~/.openclaw/workspace/config/mcporter.json | python3 -m json.tool

# 3. 查看 MCP 错误日志
openclaw mcp logs weather --tail 20

# 4. 检查依赖是否安装
npm list @modelcontextprotocol/sdk
```

### Q2: HTTP/SSE 方式的 MCP Server 连接超时？

**A**: 检查以下几点：
1. Server 是否已经启动并监听指定端口
2. `baseUrl` 是否包含正确的路径（通常以 `/mcp` 结尾）
3. 防火墙是否放行了对应端口
4. 增大 `timeout` 配置值

### Q3: 自定义 MCP Server 的工具在 Agent 侧不显示？

**A**: 确认以下几点：
- `mcporter.json` 中 `enabled` 不是 `false`
- Server 启动后能正确响应 `tools/list` 请求
- 执行 `openclaw mcp reload` 重新加载配置
- 检查工具的 `description` 是否为空（空描述的工具可能被过滤）

### Q4: MCP 和 Skill 可以同时使用吗？

**A**: 完全可以。MCP 工具和 Skill 在 Agent 推理时共存，Agent 会根据任务需求自行选择最合适的工具。Skill 适合实现完整的自动化流程，MCP 适合提供原子化的工具能力。两者互补使用效果最佳。

### Q5: 如何限制 Agent 对 MCP 工具的调用权限？

**A**: 通过 OpenClaw 的执行审批机制（exec-approvals）控制：

```json
// exec-approvals.json
{
  "mcp:weather:get_weather": "auto",
  "mcp:weather:get_forecast": "auto",
  "mcp:filesystem:write_file": "manual",
  "mcp:github:*": "manual"
}
```

设为 `"manual"` 的工具调用需要用户确认后才会执行。

---

## 本章小结

- **MCP（Model Context Protocol）** 是 AI Agent 工具集成的标准化协议，采用 JSON-RPC 2.0 通信，支持 stdio 和 HTTP/SSE 两种传输方式。
- **与传统方式对比**：MCP 相比直接调用 REST API 或使用 Skill，具有更高的复用性、可发现性和安全性。
- **内置 MCP 工具**：OpenClaw 预集成了 GitHub、文件系统、搜索等 MCP Server，通过 `mcporter.json` 即可启用。
- **自定义开发**：可使用 Node.js SDK 或 Python SDK 快速开发 MCP Server，核心是定义工具的 `name`、`description` 和 `inputSchema`。
- **调试与测试**：使用 `openclaw mcp list/tools/call` 命令调试，使用 MCP Inspector 进行交互式调试，编写自动化测试保障质量。
- **生态丰富**：官方和社区维护了大量 MCP Server，新 Agent 能力的扩展成本很低。
- 遇到问题时，优先使用 `openclaw mcp logs` 查看日志，用 MCP Inspector 隔离测试。

---
[⬅️ 上一章：Memory 记忆系统深入](15-Memory%20记忆系统深入.md) | [📑 目录](README.md) | [➡️ 下一章：浏览器自动化与网页交互](17-浏览器自动化与网页交互.md)
---
