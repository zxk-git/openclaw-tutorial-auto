<div align="center">

[← 第 20 章](20-OpenClaw 生态与未来展望.md) · [📑 目录](README.md) · [📋 大纲](OUTLINE.md)

</div>

# 第 21 章：多飞书多 Agent 实战配置

![difficulty](https://img.shields.io/badge/难度-⭐⭐⭐⭐_高级-red) ![time](https://img.shields.io/badge/阅读时间-19_分钟-blue) ![chapter](https://img.shields.io/badge/章节-21%2F21-purple)


> **难度**: ⭐⭐⭐⭐ 高级 | **预计阅读**: 25 分钟 | **前置章节**: [第 7 章](07-飞书集成与消息自动化.md)、[第 8 章](08-单 Gateway 多 Agent 配置与管理.md)


## 📑 本章目录

- [21.1 场景与目标](#211-场景与目标)
- [21.2 前置条件](#212-前置条件)
- [21.3 创建第二个飞书应用](#213-创建第二个飞书应用)
- [21.4 配置多飞书账号](#214-配置多飞书账号)
- [深度连接验证](#深度连接验证)
- [21.5 创建独立 Agent 与工作空间](#215-创建独立-agent-与工作空间)
- [21.6 自定义工作空间文件](#216-自定义工作空间文件)
- [核心能力](#核心能力)
- [交互风格](#交互风格)
- [原则](#原则)
- [风格](#风格)
- [删除 BOOTSTRAP.md](#删除-bootstrapmd)
- [21.7 路由绑定与验证](#217-路由绑定与验证)
- [应用配置](#应用配置)
- [21.8 消息测试](#218-消息测试)
- [验证 Agent 路由](#验证-agent-路由)
- [21.9 Cron 任务分流](#219-cron-任务分流)
- [编辑现有 Cron 任务](#编辑现有-cron-任务)
- [实操练习](#实操练习)
- [常见问题 (FAQ)](#常见问题-faq)
- [参考资料](#参考资料)
- [本章小结](#本章小结)

> 本章是一个完整的实战教程，基于真实部署经验，演示如何在同一台服务器上配置多个飞书机器人，每个绑定独立的 Agent、工作空间和身份。适用于需要"通用助手 + 专业助手"分工协作的场景。

---

## 21.1 场景与目标

### 为什么需要多飞书多 Agent？

单飞书机器人 + 单 Agent 的架构在简单场景下够用，但当需求增长时会遇到瓶颈：

| 痛点 | 说明 |
|------|------|
| 角色混淆 | 同一个机器人既要做通用问答又要写代码，人格不一致 |
| 上下文污染 | 代码任务的 memory 和日常闲聊混在一起 |
| 群聊混乱 | 不同群需要不同风格的响应 |

**解决方案**：多飞书 App × 多 Agent，1:1 绑定。

### 本章目标架构

```text
Gateway (端口 18789)
│
├── feishu[default]  ←→  main Agent (🤖 小光)
│   ├── App ID: cli_a9280c02b7fa1cb1
│   ├── Workspace: ~/.openclaw/workspace/
│   └── 角色: 通用助手（日常问答、任务管理、飞书自动化）
│
└── feishu[coding-bot]  ←→  coding Agent (💻 代码助手)
    ├── App ID: cli_a924fdf77ef7dcd5
    ├── Workspace: ~/.openclaw/workspace-coding/
    └── 角色: 代码专家（编程、审查、架构、调试）
```

---

## 21.2 前置条件

在配置多飞书多 Agent 之前，需要确保基础环境已就绪。本章操作涉及多个飞书应用和多个 Agent 工作空间的创建与关联，如果基础环境有问题（Gateway 未运行、Token 过期等），后续步骤会频繁报错。建议先完成以下检查清单：

- [x] OpenClaw 已安装并运行（v2026.3.x+）
- [x] 至少一个飞书 App 已配置（参考[第 7 章](07-飞书集成与消息自动化.md)）
- [x] 飞书 SDK 已安装：`@larksuiteoapi/node-sdk`
- [x] Gateway 以 systemd 服务运行
- [x] 当前用户有读写 `~/.openclaw/` 目录的权限

### 检查当前状态

```bash
# 查看现有 channels
openclaw channels list

# 查看现有 agents
openclaw agents

# 确认 feishu SDK
ls /usr/lib/node_modules/openclaw/node_modules/@larksuiteoapi/

# 确认 OpenClaw 版本（需 2026.3.x+）
openclaw --version

# 验证 Gateway 运行状态和连通性
openclaw gateway status --deep
```

如果上述命令出现异常，先按以下清单排查：

| 异常情况 | 可能原因 | 修复方法 |
|----------|----------|----------|
| `channels list` 无输出 | 尚未配置任何飞书渠道 | 先完成 [第 7 章](07-飞书集成与消息自动化.md) 的基础配置 |
| `agents` 只显示 main | 正常——尚未添加额外 Agent | 继续本章后续步骤 |
| `@larksuiteoapi` 目录不存在 | 飞书 SDK 未安装 | 执行 `npm install -g @larksuiteoapi/node-sdk` |
| Gateway 状态为 inactive | 服务未启动或已崩溃 | 执行 `openclaw daemon start` 并检查日志 |

> [!TIP]
> 多飞书多 Agent 配置步骤较多，建议在开始之前先对当前配置做一次完整备份：`cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak-$(date +%Y%m%d)`。这样即使配置出错也能快速回滚到已知可用状态。

---

## 21.3 创建第二个飞书应用

### Step 1: 在飞书开发者后台创建应用

1. 登录 [飞书开发者后台](https://open.feishu.cn/app)
2. 点击 **创建自建应用**
3. 填写应用信息：
   - 名称：` 代码助手 `（或你的自定义名称）
   - 描述：专注于编程和软件开发的 AI 助手

### Step 2: 配置应用权限

在 **权限管理** 中启用以下权限。这些权限决定了机器人能在飞书中执行哪些操作——权限不足会导致特定功能报 `Permission denied` 错误，权限过多则不符合最小权限原则。建议根据实际需求逐步开启：

| 权限 | 说明 | 必须 | 使用场景 |
|------|------|------|----------|
| `im:message` | 读取和发送消息 | ✅ | 基础对话功能 |
| `im:message:send_as_bot` | 以机器人身份发送消息 | ✅ | 主动推送消息、Cron 定时投递 |
| `im:chat` | 群聊操作（获取群信息、群成员列表） | ✅ | 群聊场景下的上下文感知 |
| `im:resource` | 获取消息中的资源文件（图片、文件等） | 推荐 | 处理用户发送的图片或文件附件 |
| `contact:user.base:readonly` | 读取用户基本信息 | 推荐 | 在消息中显示用户名而非 user_id |

配置完权限后，需要在页面底部点击 **批量开通** 按钮，然后在弹出的确认框中提交。部分权限（如 `contact` 类）可能需要企业管理员审批。

> [!TIP]
> 如果你不确定某个权限是否需要，可以先只开启前三个必须权限。后续使用中如果 OpenClaw 日志报出 `permission denied` 错误并附带具体权限名，再按需补开即可。

### Step 3: 启用机器人能力

在 **应用能力** → **机器人** 中启用机器人功能。

### Step 4: 获取凭证

在 **凭证与基础信息** 中记录：
- **App ID**：`cli_xxxxxxxxxx`
- **App Secret**：对应的密钥

### Step 5: 发布应用

在 **版本管理与发布** 中提交审核并发布（企业自建应用通常秒过）。

---

## 21.4 配置多飞书账号

### 关键概念：accounts 嵌套结构

OpenClaw 的飞书多账号使用 `channels.feishu.accounts` 嵌套对象：

```json
{
  "channels": {
    "feishu": {
      "enabled": true,
      "connectionMode": "websocket",
      "dmPolicy": "open",
      "groupPolicy": "open",
      "requireMention": true,
      "allowFrom": ["*"],
      "accounts": {
        "default": {
          "appId": "cli_第一个 App 的 ID",
          "appSecret": "第一个 App 的 Secret"
        },
        "coding-bot": {
          "appId": "cli_第二个 App 的 ID",
          "appSecret": "第二个 App 的 Secret",
          "name": "Coding Bot"
        }

      }
    }
  }
}
```

#### 配置要点

| 字段 | 说明 |
|------|------|
| `accounts` 键名 | 即账号 ID（`default`、`coding-bot`），用于路由引用 |
| 顶层字段 | `connectionMode` 等为所有账号的默认值 |
| 账号级字段 | 可覆盖顶层默认值（如单独设置 `dmPolicy`） |
| `name` | 显示名称，用于 `openclaw channels list` 输出 |

### 手动编辑 vs CLI

**方式一：手动编辑** `~/.openclaw/openclaw.json`

将原有的单账号扁平结构：

```json
{
  "channels": {
    "feishu": {
      "appId": "cli_xxx",
      "appSecret": "secret",
      "enabled": true,
      "connectionMode": "websocket"
    }
  }
}
```

改为 accounts 嵌套结构（如上）。

**方式二：CLI 添加**

```bash
openclaw channels add \
  --channel feishu \
  --account coding-bot \
  --name "Coding Bot"
```

> ⚠️ **注意**：CLI `channels add` 会自动将现有单账号迁移到 `accounts.default`，但建议手动编辑确保配置准确。

### 验证配置

```bash
# 重启 Gateway 使配置生效
openclaw gateway restart

# 检查是否有配置错误
openclaw channels list
```

正确输出应显示两个账号：

```text
Chat channels:
- Feishu coding-bot (Coding Bot): configured, enabled
- Feishu default: configured, enabled
```

## 深度连接验证

深度验证会对每个渠道执行端到端探测，包括 API 鉴权、Webhook 回调连通性以及 WebSocket 长连接状态检查，确保消息通路完全畅通。

```bash
# 执行深度探测（会逐一向各渠道发送测试请求）
openclaw channels status --probe
```

期望输出：

```text
- Feishu coding-bot (Coding Bot): enabled, configured, running, works
- Feishu default: enabled, configured, running, works
```

如果状态显示非 `works`，可进一步排查：

```bash
# 检查飞书 API 端点连通性
curl -s -o /dev/null -w "%{http_code}" https://open.feishu.cn/open-apis/bot/v2/hook/ping

# 检查 Gateway 的 WebSocket 连接状态
openclaw doctor --check websocket

# 查看渠道相关的错误日志
tail -20 ~/.openclaw/logs/config-audit.jsonl | grep -i feishu
```

> 💡 **提示**：如果某个渠道显示 `configured` 但非 `works`，通常是飞书 App 的权限配置或事件订阅地址不正确，请回到飞书开放平台检查应用配置。

---

## 21.5 创建独立 Agent 与工作空间

### 一键创建 Agent

```bash
openclaw agents add coding \
  --workspace ~/.openclaw/workspace-coding \
  --bind feishu:coding-bot \
  --model github-copilot/gpt-4.1 \
  --non-interactive
```

这条命令自动完成：
1. 在配置中注册新 Agent `coding`
2. 创建工作空间 `~/.openclaw/workspace-coding/`（含默认模板文件）
3. 创建 Agent 状态目录 `~/.openclaw/agents/coding/`
4. 添加路由绑定：`feishu:coding-bot` → `coding` Agent

### 设置身份

```bash
openclaw agents set-identity \
  --agent coding \
  --name "代码助手" \
  --emoji "💻"
```

### 验证创建结果

```bash
openclaw agents
```

期望输出：

```yaml
Agents:
- main (default)
  Identity: 🤖 小光 (IDENTITY.md)
  Workspace: ~/.openclaw/workspace
  Model: github-copilot/gpt-4.1
  Routing: default (no explicit rules)

- coding
  Identity: 💻 代码助手 (IDENTITY.md)
  Workspace: ~/.openclaw/workspace-coding
  Model: github-copilot/gpt-4.1
  Routing: Feishu coding-bot
```

---

## 21.6 自定义工作空间文件

新创建的工作空间包含英文默认模板，需要根据角色进行自定义。

### 文件清单

| 文件 | 用途 | 是否必须自定义 |
|------|------|----------------|
| `IDENTITY.md` | 角色身份定义 | ✅ 必须 |
| `SOUL.md` | 行为准则与人格 | ✅ 必须 |
| `USER.md` | 用户信息 | ✅ 必须 |
| `AGENTS.md` | 会话启动流程 | ✅ 推荐 |
| `TOOLS.md` | 环境与工具配置 | 推荐 |
| `MEMORY.md` | 长期记忆 | 初始留空即可 |
| `HEARTBEAT.md` | 心跳任务 | 按需 |
| `BOOTSTRAP.md` | 首次启动引导 | 删除（已完成初始化） |

### IDENTITY.md 示例

```markdown
# 💻 代码助手 (Coding Bot)

- **Name:** 代码助手
- **Creature:** AI 编程专家
- **Vibe:** 专业、高效、直接
- **Emoji:** 💻

---

## 核心能力

- 代码编写与审查（Python、JavaScript、Go、Rust、Java 等）
- 架构设计（系统架构、数据库模型、API 接口）
- 调试排错（错误日志分析、Bug 定位、修复方案）
- 最佳实践（代码规范、性能优化、安全审计）

## 交互风格

- 直接给出可运行的代码，而非抽象建议
- 中文沟通，代码注释使用英文
- 遇到多种方案时，先推荐最佳实践
```

### SOUL.md 示例

```markdown
# SOUL.md

你是**代码助手**，不是聊天机器人。

## 原则

- **代码优先**：能用代码说明的不用文字解释
- **结果导向**：少客套，直接给答案或方案
- **有判断**：可以不同意用户方案，但必须给理由

## 风格

- 直接、简洁、专业
- 中文沟通，代码注释英文
```

### USER.md — 复用主工作空间内容

```bash
# 直接从主工作空间复制
cp ~/.openclaw/workspace/USER.md ~/.openclaw/workspace-coding/USER.md
```

## 删除 BOOTSTRAP.md

`BOOTSTRAP.md` 是 OpenClaw 初始化向导文件，用于首次引导 Agent 完成自我配置。新工作空间创建后，必须删除此文件，否则 Agent 每次启动时都会重复执行引导流程，可能覆盖你已经自定义的配置。

```bash
# 删除引导文件
rm ~/.openclaw/workspace-coding/BOOTSTRAP.md

# 验证文件已被删除
ls ~/.openclaw/workspace-coding/BOOTSTRAP.md 2>&1
# 应输出：No such file or directory
```

> ⚠️ **注意**：如果忘记删除 `BOOTSTRAP.md`，Agent 在下次对话时会进入引导模式而非正常工作模式。如果误删了其他文件，可通过 `openclaw onboard --agent coding` 重新生成引导文件。

## 创建 memory 目录

```bash
mkdir -p ~/.openclaw/workspace-coding/memory
```

---

## 21.7 路由绑定与验证

### 路由规则解释

OpenClaw 通过 `bindings` 数组将渠道账号映射到 Agent：

```json
{
  "bindings": [
    {
      "type": "route",
      "agentId": "coding",
      "match": {
        "channel": "feishu",
        "accountId": "coding-bot"
      }
    }
  ]
}
```

| 路由规则 | 匹配规则 | 目标 Agent |
|----------|----------|------------|
| 无规则匹配 | 所有未匹配的消息 | main（默认） |
| `feishu:coding-bot` | coding-bot 账号的所有消息 | coding |

### 管理路由的 CLI 命令

```bash
# 查看所有绑定
openclaw agents bindings --json

# 添加新绑定
openclaw agents bind --agent coding --bind feishu:coding-bot

# 移除绑定
openclaw agents unbind --agent coding --bind feishu:coding-bot
```

## 应用配置

修改路由绑定后，需要重启 Gateway 使新的配置生效。重启过程会短暂中断服务（通常 1-2 秒），请在业务低峰期操作。

```bash
# 重启 Gateway 应用新配置
openclaw gateway restart

# 验证 Gateway 已正常启动
openclaw daemon status
# 应显示 running 状态

# 确认新的路由绑定已生效
openclaw agents
# 检查输出中 coding Agent 的 Routing 行是否包含新绑定的渠道
```

如果重启后出现异常，可快速回滚：

```bash
# 查看配置变更记录
tail -10 ~/.openclaw/logs/config-audit.jsonl

# 回滚到上一次配置（如果有备份）
cp ~/.openclaw/openclaw.json.bak ~/.openclaw/openclaw.json
openclaw gateway restart
```

> 💡 **提示**：建议在修改配置前先备份当前配置文件：`cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak`。

## 验证路由

```bash
openclaw agents
```

确认 `coding` Agent 的 Routing 行显示 `Feishu coding-bot`。

---

## 21.8 消息测试

### 前提：将机器人添加到群聊

在飞书群设置中，将第二个机器人（Coding Bot）添加为群成员。

> ⚠️ 未加群会收到 `230002: Bot/User can NOT be out of the chat` 错误。

### 通过 CLI 发送测试消息

```bash
# 通过 coding-bot 发消息到飞书群
openclaw message send \
  --channel feishu \
  --account coding-bot \
  --target "oc_你的群聊 ID" \
  --message "💻 Coding Bot 上线！这是来自代码助手的测试消息。"

# 通过 default 发消息（对比）
openclaw message send \
  --channel feishu \
  --account default \
  --target "oc_你的群聊 ID" \
  --message "🤖 小光报到！这是来自默认机器人的消息。"
```

## 验证 Agent 路由

在飞书中分别 @两个机器人发消息：
1. @小光 → 问一个日常问题 → 应由 main Agent 回复
2. @代码助手 → 问一个代码问题 → 应由 coding Agent 回复

检查日志确认路由：

```bash
openclaw channels logs --channel feishu | tail -20
```

### 消息测试排查清单

如果测试中消息未按预期路由，按以下步骤逐一排查：

```bash
# 1. 确认两个飞书连接都在线
openclaw channels status --probe

# 2. 确认路由绑定正确
openclaw agents --json | jq '.[] | {name: .name, bindings: .bindings}'

# 3. 查看实时日志，观察消息进入哪个 Agent
openclaw logs --follow --filter "routing"

# 4. 如果消息全部进入 main，检查 accountId 匹配
openclaw agents bindings --json
```

| 症状 | 可能原因 | 解决方法 |
|------|----------|----------|
| 两个机器人都回复了同一条消息 | 两个 App 在同一群且 `requireMention` 为 false | 设置 `requireMention: true` |
| @代码助手 无回复 | coding-bot 连接未建立或路由绑定缺失 | 检查 `channels status --probe` 和 `agents bindings` |
| 回复内容风格不对 | 工作空间的 SOUL.md 未自定义 | 检查 `~/.openclaw/workspace-coding/SOUL.md` 内容 |
| 收到 403 错误 | 飞书 App 权限不足 | 按 [21.3 Step 2](#step-2-配置应用权限) 补充权限 |

> [!TIP]
> 测试阶段建议将日志级别设为 debug 以获取最详细的路由信息：`export OPENCLAW_LOG_LEVEL=debug && openclaw daemon restart`。测试完成后记得改回 `info` 避免日志文件快速膨胀。

---

## 21.9 Cron 任务分流

### 指定投递账号

Cron 任务的投递消息可以指定使用哪个飞书账号：

```bash
# 默认投递（通过 default 账号）
openclaw cron add \
  --schedule "0 8 * * *" \
  --channel feishu \
  --message "每日工作总结"

# 指定 coding-bot 投递
openclaw cron add \
  --schedule "0 */6 * * *" \
  --channel feishu \
  --account coding-bot \
  --message "代码质量检查报告"
```

## 编辑现有 Cron 任务

在 `~/.openclaw/cron/jobs.json` 中为任务添加 `accountId` 字段以指定投递账号。如果不指定 `accountId`，任务消息将通过 `default` 账号发送并路由到 `main` Agent：

```json
{
  "id": "code-quality-check",
  "schedule": "0 */6 * * *",
  "channel": "feishu",
  "accountId": "coding-bot",
  "target": "oc_群聊ID",
  "message": "请执行代码质量检查并生成报告",
  "deliverTo": {
    "agentId": "coding"
  }
}
```

### Cron 多账号配置要点

| 字段 | 说明 | 是否必须 |
|------|------|----------|
| `accountId` | 指定使用哪个飞书账号发送消息 | 多账号时推荐 |
| `deliverTo.agentId` | 指定由哪个 Agent 处理该任务 | 多 Agent 时推荐 |
| `target` | 飞书群聊或用户的 open_id / chat_id | ✅ 必须 |

修改 `jobs.json` 后需重载 Cron 配置：

```bash
openclaw cron reload   # 热重载，无需重启 Gateway
openclaw cron list     # 确认任务列表和账号绑定
```

> [!TIP]
> 多 Agent 场景下，建议为每个 Agent 的 Cron 任务设置不同的错峰时间，避免多个 Agent 同时执行高负载任务导致 AI API 限流。例如主 Agent 在整点执行，coding Agent 在半点执行。

---

## 实操练习

### 练习 1：基础——添加第二个飞书机器人并验证连接

1. 在飞书开发者后台创建新应用
2. 修改 `openclaw.json` 添加 `accounts` 嵌套结构
3. 重启 Gateway 并用 `openclaw channels status --probe` 验证
4. 预期结果：两个飞书账号都显示 `running, works`

### 练习 2：进阶——创建独立 Agent 并测试路由

1. 使用 `openclaw agents add` 创建新 Agent
2. 自定义 IDENTITY.md 和 SOUL.md
3. 在飞书中分别 @两个机器人，验证回复来自不同 Agent
4. 预期结果：不同机器人的回复风格和知识库各自独立

### 练习 3：高级——配置 Agent 间协作

1. 在 coding Agent 的 TOOLS.md 中添加主工作空间路径
2. 测试 coding Agent 是否能读取主工作空间的技能文件
3. 设置共享 memory 目录供两个 Agent 使用

---

## 常见问题 (FAQ)

### Q1: `unknown channel id: feishu:coding-bot` 配置错误

**原因**：使用了 `channels["feishu:coding-bot"]` 格式（顶层键名带冒号），这不是合法的 channel ID。

**解决**：使用 `channels.feishu.accounts.coding-bot` 嵌套格式：

```json
{
  "channels": {
    "feishu": {
      "accounts": {
        "coding-bot": { "appId": "...", "appSecret": "..." }
      }
    }
  }
}
```

### Q2: 230002 `Bot/User can NOT be out of the chat`

**原因**：机器人未被添加到目标飞书群。

**解决**：在飞书群设置 → 群成员 → 添加机器人 中添加对应的 App。

### Q3: 两个机器人收到同一条消息

**原因**：两个 App 都在同一个群中，群消息对所有群成员可见。

**解决**：使用 `requireMention: true` 确保只响应 @提及的消息，或将不同机器人放在不同群中。

### Q4: Agent 创建后路由不生效

**原因**：需要重启 Gateway。

**解决**：

```bash
openclaw gateway restart
openclaw agents  # 确认 Routing 行显示正确的绑定
```

### Q5: 如何把现有单账号迁移到多账号？

**步骤**：
1. 备份配置：`cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak`
2. 将 `appId`/`appSecret` 从顶层移入 `accounts.default`
3. 添加新账号到 `accounts`
4. 删除顶层的 `appId`/`appSecret`
5. 重启 Gateway 验证

---

## 参考资料

- [第 7 章：飞书集成与消息自动化](07-飞书集成与消息自动化.md) — 单飞书 App 配置基础
- [第 8 章：单 Gateway 多 Agent 配置与管理](08-单 Gateway 多 Agent 配置与管理.md) — 多 Agent 架构理论
- [飞书开发者文档](https://open.feishu.cn/document/) — App 创建与权限管理
- [OpenClaw CLI 参考](https://docs.OpenClaw.ai/cli/channels) — Channels 命令详解

---


## Troubleshooting

### 配置保存后 Gateway 启动报 JSON 语法错误

**原因**：手动编辑 `openclaw.json` 时引入了尾逗号或缺少引号。

**排查**：

```bash
python3 -m json.tool ~/.openclaw/openclaw.json
# 输出错误行号，修正后重新保存
```

## Agent 创建成功但消息不触达

**排查步骤**：

1. 确认飞书 App 已发布且机器人已添加到目标群聊
2. 确认路由绑定正确：`openclaw agents --json | jq '.[].bindings'`
3. 检查 Gateway 日志：`journalctl --user -u openclaw-gateway --no-pager -n 30`
4. 测试连通性：`openclaw channels status --probe`

### Cron 任务投递到错误的 Agent

**原因**：`jobs.json` 中任务未指定 `deliverTo` 字段，默认投递到 `main` Agent。

**解决**：在任务定义中明确指定目标账号和 Agent：

```json
{
  "deliverTo": { "channel": "feishu", "account": "coding-bot" }
}
```

---

## 本章小结

本章通过真实部署实例，完整演示了多飞书多 Agent 架构的配置过程：

| 步骤 | 操作 | 产物 |
|------|------|------|
| 1️⃣ 创建飞书 App | 开发者后台 | 获得 App ID + Secret |
| 2️⃣ 配置多账号 | `openclaw.json` accounts 嵌套 | 双飞书连接 |
| 3️⃣ 创建 Agent | `openclaw agents add` | 独立 Agent + 工作空间 |
| 4️⃣ 自定义工作空间 | 编辑 IDENTITY/SOUL/USER.md | 角色个性化 |
| 5️⃣ 路由绑定 | `--bind feishu:coding-bot` | 消息自动分流 |
| 6️⃣ 测试验证 | `channels status --probe` | 全链路验证 |

**核心要点**：
- 多飞书用 `accounts` **嵌套**结构，不是顶层多 key
- `openclaw agents add --bind` **一键**完成 Agent 创建 + 路由绑定
- 每个 Agent 的工作空间**完全隔离**（记忆、技能、身份独立）
- 未匹配路由的消息默认走 `main` Agent

---

> 🔗 **下一步建议**：给新 Agent 配置专属 Cron 任务，或为不同 Agent 选择不同的 AI 模型（如 Claude vs GPT-4.1），实现能力互补。

---

<div align="center">

[← 上一章：OpenClaw 生态与未来展望](20-OpenClaw 生态与未来展望.md) · [📑 返回目录](README.md)

</div>
