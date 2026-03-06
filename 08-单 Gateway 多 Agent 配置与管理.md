---
[⬅️ 上一章：飞书集成与消息自动化](07-飞书集成与消息自动化.md) | [📑 目录](README.md) | [➡️ 下一章：故障排查与日志分析](09-故障排查与日志分析.md)
---

# 第8章：单 Gateway 多 Agent 配置与管理

> **难度**: ⭐⭐⭐ 进阶 | **预计阅读**: 20 分钟 | **前置章节**: [第 2 章](02-部署与环境初始化.md)

> 本章讲解如何在单个 Gateway 下配置和管理多个 Agent，实现多项目隔离、多角色协作。这是 OpenClaw 中高级运维的核心能力。适用于需要在同一台机器或同一集群中运行多个独立 AI 助手的场景，如团队内多角色分工、多项目 DevOps 自动化等。

## 📑 本章目录

- [8.1 多 Agent 架构](#81-多-agent-架构)
  - [8.1.1 整体架构图](#811-整体架构图)
  - [8.1.2 核心概念一览](#812-核心概念一览)
  - [8.1.3 隔离优势](#813-隔离优势)
- [8.2 Agent 配置与创建](#82-agent-配置与创建)
  - [8.2.1 创建新 Agent](#821-创建新-agent)
  - [8.2.2 Agent 配置参数详解](#822-agent-配置参数详解)
  - [8.2.3 路由配置](#823-路由配置)
  - [8.2.4 配置热加载](#824-配置热加载)
- [8.3 Agent 间通信与协作](#83-agent-间通信与协作)
  - [8.3.1 协作模式对比](#831-协作模式对比)
  - [8.3.2 共享记忆目录](#832-共享记忆目录)
  - [8.3.3 消息转发](#833-消息转发)
  - [8.3.4 Agent 协作示例](#834-agent-协作示例)
- [8.4 资源管理与监控](#84-资源管理与监控)
  - [8.4.1 资源限制配置](#841-资源限制配置)
  - [8.4.2 监控命令](#842-监控命令)
  - [8.4.3 性能调优建议](#843-性能调优建议)
- [8.5 实操练习](#85-实操练习)
- [8.6 常见问题 (FAQ)](#86-常见问题-faq)
- [8.7 外部参考](#87-外部参考)
- [本章小结](#本章小结)

---

## 8.1 多 Agent 架构

OpenClaw 支持在单个 Gateway 下运行多个 Agent，每个 Agent 有独立的身份、记忆和技能配置。Gateway 充当统一的消息路由层，负责将来自不同渠道的请求分发到对应的 Agent 进行处理。

### 8.1.1 整体架构图

```text
Gateway (端口 18789) ─── 统一入口
├── Agent 1: 技术助手 (workspace-1/)
│   ├── IDENTITY.md     → 技术专家身份
│   ├── SOUL.md         → 严谨分析风格
│   ├── skills/         → 编程、调试相关
│   └── memory/         → 技术笔记
├── Agent 2: 运营助手 (workspace-2/)
│   ├── IDENTITY.md     → 运营分析师身份
│   ├── SOUL.md         → 数据驱动风格
│   ├── skills/         → 数据分析相关
│   └── memory/         → 运营报告
└── Agent 3: 项目助手 (workspace-3/)
    ├── IDENTITY.md     → 项目经理身份
    ├── SOUL.md         → 结构化沟通风格
    ├── skills/         → 任务管理相关
    └── memory/         → 项目进展
```

### 8.1.2 核心概念一览

| 概念 | 说明 | 存储位置 |
|------|------|----------|
| Gateway | 统一消息入口，负责路由和负载均衡 | `openclaw.json` |
| Agent | 独立的 AI 实体，拥有自己的身份和配置 | `~/.openclaw/agents/<name>/` |
| Workspace | Agent 的工作目录，存放身份、记忆、技能 | `agents/<name>/workspace/` |
| 路由规则 | 根据渠道/关键词将请求分发到指定 Agent | `openclaw.json` 的 `routing` 字段 |
| 共享记忆 | 跨 Agent 共用的数据存储区域 | `~/.openclaw/workspace/shared-memory/` |

每个 Agent 拥有完全独立的：
- **IDENTITY.md** — 身份定义（名字、角色、专长）
- **SOUL.md** — 行为准则（风格、边界、价值观）
- **memory/** — 记忆区（互不干扰）
- **skills/** — 技能集（按需配置）
- **config/** — 独立配置（模型选择、参数调优等）

### 8.1.3 隔离优势

- 不同 Agent 可以有不同的 AI 模型配置（如 Agent 1 用 Claude，Agent 2 用 GPT-4）
- 技能冲突不会跨 Agent 影响
- 记忆和上下文完全隔离，保证数据安全
- 独立升级和回滚，不影响其他 Agent 的运行

可以通过以下命令快速验证当前 Gateway 下有哪些 Agent：

```bash
# 查看已注册的 Agent 列表
openclaw agents list
```

---

## 8.2 Agent 配置与创建

### 8.2.1 创建新 Agent

下面以创建一个"运营助手"Agent 为例，完整演示创建流程：

```bash
# 1. 创建 Agent workspace 目录
mkdir -p ~/.openclaw/agents/agent-2/workspace
cd ~/.openclaw/agents/agent-2/workspace

# 2. 创建身份文件
cat > IDENTITY.md << 'EOF'
---
name: 运营助手
role: 运营数据分析与报告生成
style: 专业严谨，数据驱动
---
# 运营助手

我是一个专注于运营数据分析的 AI 助手。

## 核心能力
- 数据报表自动生成
- 竞品监控与分析
- 用户反馈整理
EOF

# 3. 创建行为准则
cat > SOUL.md << 'EOF'
## 行为准则
- 以数据说话，避免主观判断
- 报告格式清晰、结构化
- 敏感数据脱敏处理
EOF

# 4. 创建记忆和技能目录
mkdir -p memory/ skills/ config/

# 5. 验证 workspace 结构
tree ~/.openclaw/agents/agent-2/workspace/
```

### 8.2.2 Agent 配置参数详解

每个 Agent 支持以下配置项，可在 `openclaw.json` 的 `agents` 字段中定义：

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `workspace` | string | 必填 | Agent 的 workspace 目录路径 |
| `channels` | string[] | `[]` | 绑定的消息渠道列表 |
| `model` | string | 继承全局 | 使用的 AI 模型名称 |
| `maxConcurrent` | number | `5` | 最大并发请求数 |
| `memoryLimit` | string | `"256MB"` | 内存使用上限 |
| `timeout` | number | `600` | 单次请求超时时间（秒） |
| `enabled` | boolean | `true` | 是否启用此 Agent |

### 8.2.3 路由配置

在 Gateway 配置中设置 Agent 路由规则，将不同渠道或用户映射到不同 Agent。

```json
{
  "agents": {
    "agent-1": {
      "workspace": "~/.openclaw/agents/agent-1/workspace",
      "channels": ["feishu:group-tech"],
      "model": "claude-sonnet-4-20250514",
      "enabled": true
    },
    "agent-2": {
      "workspace": "~/.openclaw/agents/agent-2/workspace",
      "channels": ["feishu:group-ops"],
      "model": "gpt-4o",
      "enabled": true
    }
  }
}
```

配置完成后验证路由是否生效：

```bash
# 检查路由配置是否正确
openclaw config validate

# 查看当前生效的路由映射
openclaw agents routes
```

### 8.2.4 配置热加载

修改 Agent 配置后，Gateway 支持热加载而不中断服务：

```bash
# 发送信号触发重载
openclaw gateway reload

# 或通过 API
curl -X POST http://localhost:18789/admin/reload

# 验证重载结果
openclaw agents list --verbose
```

> [!TIP]
> 热加载仅更新配置层面的变更（如路由规则、模型切换），Agent 的 workspace 文件变更（如 IDENTITY.md）会在下一次请求时自动读取，无需重载。

---

## 8.3 Agent 间通信与协作

多个 Agent 可以通过共享文件或消息通道进行协作。合理设计协作模式可以实现复杂的多步骤自动化流水线。

### 8.3.1 协作模式对比

| 协作模式 | 适用场景 | 优点 | 缺点 |
|----------|----------|------|------|
| 共享文件 | 异步数据交换 | 简单可靠，易于调试 | 实时性较差 |
| 消息转发 | 请求级联处理 | 实时性好，链路清晰 | 配置相对复杂 |
| Cron 定时协作 | 定期汇总分析 | 自动化程度高 | 存在时间延迟 |
| API 直接调用 | 即时协作 | 响应最快 | 耦合度较高 |

### 8.3.2 共享记忆目录

```text
~/.openclaw/
├── workspace/shared-memory/     ← 所有 Agent 可访问
│   ├── project-status.json      ← 共享项目状态
│   └── team-notes.md            ← 团队笔记
├── agents/
│   ├── agent-1/workspace/       ← Agent 1 专属
│   └── agent-2/workspace/       ← Agent 2 专属
```

创建共享记忆目录并初始化：

```bash
# 创建共享记忆区
mkdir -p ~/.openclaw/workspace/shared-memory

# 初始化共享状态文件
cat > ~/.openclaw/workspace/shared-memory/project-status.json << 'EOF'
{
  "lastUpdated": "2026-03-06",
  "activeProjects": [],
  "sharedNotes": []
}
EOF
```

### 8.3.3 消息转发

Gateway 支持将消息从一个 Agent 转发到另一个 Agent 处理：

```json
{
  "routing": {
    "rules": [
      {"pattern": "技术问题.*", "target": "agent-1"},
      {"pattern": "运营报告.*", "target": "agent-2"},
      {"pattern": "项目进度.*", "target": "agent-3"},
      {"pattern": "default", "target": "agent-1"}
    ]
  }
}
```

路由规则按照从上到下的顺序匹配，第一条匹配的规则生效。`"default"` 规则作为兜底，处理所有未匹配的请求。

### 8.3.4 Agent 协作示例

场景：技术助手生成报告 → 运营助手分析数据 → 项目助手汇总进度

```bash
# Step 1: Agent 1 (技术助手) 将技术报告写入共享目录
echo "## 技术周报 - $(date +%Y-%m-%d)
- 完成功能 A 开发
- 修复 Bug #123
- 性能优化提升 20%" > ~/.openclaw/workspace/shared-memory/tech-report.md

# Step 2: Agent 2 (运营助手) 的 Cron 任务定期检查并生成分析
# 在 Agent 2 的 cron/jobs.json 中配置：
cat > ~/.openclaw/agents/agent-2/cron-check.json << 'EOF'
{
  "jobs": [
    {
      "name": "analyze-tech-report",
      "schedule": "0 9 * * 1",
      "command": "分析共享目录中的技术报告并生成运营洞察"
    }
  ]
}
EOF

# Step 3: 查看协作状态
cat ~/.openclaw/workspace/shared-memory/project-status.json
```

---

## 8.4 资源管理与监控

### 8.4.1 资源限制配置

为每个 Agent 设置合理的资源限制，防止单个 Agent 占用过多系统资源：

```json
{
  "agents": {
    "agent-1": {
      "maxConcurrent": 3,
      "memoryLimit": "512MB",
      "timeout": 300
    },
    "agent-2": {
      "maxConcurrent": 2,
      "memoryLimit": "256MB",
      "timeout": 600
    }
  }
}
```

### 8.4.2 监控命令

```bash
# 查看所有 Agent 状态
openclaw agents list

# 查看单个 Agent 详情（包含运行状态、活跃会话数等）
openclaw agents status agent-1

# 查看资源占用统计
openclaw agents stats

# 查看 Gateway 整体健康状态
openclaw gateway status

# 实时监控 Agent 日志输出
openclaw logs --agent agent-1 --follow
```

### 8.4.3 性能调优建议

| 场景 | 建议 | 命令/操作 |
|------|------|-----------|
| Agent 数量 > 5 | 增加 Gateway 内存限制 | 修改 `openclaw.json` 中 `gateway.memoryLimit` |
| 高并发请求 | 设置 `maxConcurrent` 限制 | 按 Agent 重要性分配并发配额 |
| 大量 Skills | 启用懒加载模式 | 设置 `"lazyLoad": true` |
| 记忆文件过多 | 定期归档和清理 | `openclaw memory archive --agent agent-1` |
| Agent 响应慢 | 检查模型配置和超时时间 | `openclaw agents status <name>` |
| 磁盘空间不足 | 清理日志和临时文件 | `openclaw cleanup --logs --temp` |

---

## 8.5 实操练习

以下练习帮助你从零搭建多 Agent 环境，建议按顺序完成。

### 练习 1：创建双 Agent 环境

**目标**：在本机创建两个 Agent（技术助手 + 运营助手），并验证隔离性。

```bash
# Step 1: 创建技术助手 Agent
mkdir -p ~/.openclaw/agents/tech-agent/workspace/{memory,skills,config}
cat > ~/.openclaw/agents/tech-agent/workspace/IDENTITY.md << 'EOF'
---
name: 技术助手
role: 代码审查与技术咨询
style: 严谨、逻辑清晰
---
# 技术助手
专注于代码质量和技术架构。
EOF

# Step 2: 创建运营助手 Agent
mkdir -p ~/.openclaw/agents/ops-agent/workspace/{memory,skills,config}
cat > ~/.openclaw/agents/ops-agent/workspace/IDENTITY.md << 'EOF'
---
name: 运营助手
role: 运营数据分析
style: 数据驱动、简洁明了
---
# 运营助手
专注于数据分析与运营洞察。
EOF

# Step 3: 验证目录结构
echo "=== 技术助手 ===" && ls ~/.openclaw/agents/tech-agent/workspace/
echo "=== 运营助手 ===" && ls ~/.openclaw/agents/ops-agent/workspace/

# Step 4: 注册到 Gateway
openclaw agents list
```

**验证要点**：确认两个 Agent 目录独立，`IDENTITY.md` 内容不同。

### 练习 2：配置路由规则并测试消息分发

**目标**：设置基于关键词的路由规则，测试消息是否正确分发到对应 Agent。

```bash
# Step 1: 编辑路由配置（手动编辑 openclaw.json 或使用命令）
# 在 openclaw.json 中添加 agents 和 routing 配置

# Step 2: 验证配置有效性
openclaw config validate

# Step 3: 重载 Gateway 使配置生效
openclaw gateway reload

# Step 4: 查看路由映射
openclaw agents routes

# Step 5: 通过 API 测试消息分发
curl -s http://localhost:18789/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "技术问题：如何优化数据库查询？"}' | jq .agentId

curl -s http://localhost:18789/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "运营报告：本周用户增长趋势"}' | jq .agentId
```

**验证要点**：包含"技术问题"的消息应路由到 tech-agent，包含"运营报告"的消息应路由到 ops-agent。

### 练习 3：实现跨 Agent 协作流水线

**目标**：搭建一个从技术报告生成到运营分析的自动化流水线。

```bash
# Step 1: 创建共享目录
mkdir -p ~/.openclaw/workspace/shared-memory/reports

# Step 2: 模拟技术助手输出报告
cat > ~/.openclaw/workspace/shared-memory/reports/weekly-tech.md << 'EOF'
# 技术周报 2026-03-06
## 完成事项
- API 接口重构完成，响应时间减少 40%
- 新增 3 个自动化测试用例
## 待处理
- 数据库迁移计划制定
EOF

# Step 3: 配置运营助手的定时检查任务
cat > ~/.openclaw/agents/ops-agent/workspace/config/watch-reports.json << 'EOF'
{
  "watch": {
    "path": "~/.openclaw/workspace/shared-memory/reports/",
    "pattern": "*.md",
    "action": "分析技术报告，提取关键指标，生成运营摘要"
  }
}
EOF

# Step 4: 验证共享文件可被两个 Agent 读取
cat ~/.openclaw/workspace/shared-memory/reports/weekly-tech.md

# Step 5: 查看协作状态
openclaw agents stats
```

**验证要点**：共享目录中的文件可以被两个 Agent 正常读写，流水线数据传递正常。

---

## 8.6 常见问题 (FAQ)

### Q1: 多个 Agent 之间如何保证数据隔离？

**A**: 每个 Agent 拥有完全独立的 workspace 目录，包括 `IDENTITY.md`、`SOUL.md`、`memory/`、`skills/` 等。Gateway 通过唯一路由规则将请求分发到指定 Agent，不会出现跨 Agent 的数据泄露。你可以通过以下命令检查隔离状态：

```bash
# 确认每个 Agent 的 workspace 路径独立
openclaw agents list --verbose
```

### Q2: Gateway 资源占用过高怎么办？

**A**: 当多个 Agent 同时处理请求时，Gateway 的内存和 CPU 占用会增加。建议从以下几方面优化：
1. 降低 `maxConcurrent` 限制每个 Agent 的并发请求数
2. 启用 `"lazyLoad": true` 让不活跃的 Agent 自动卸载技能
3. 定期清理低活跃 Agent 的缓存：`openclaw cleanup --cache`
4. 使用 `openclaw agents stats` 定位消耗最高的 Agent

### Q3: 如何在飞书中切换不同的 Agent？

**A**: 有两种方式切换 Agent：
- **渠道绑定**：在路由配置中将不同飞书群绑定到不同 Agent，用户在对应群中发消息即自动路由
- **显式指定**：通过 API 调用时传入 `agentId` 参数：`curl -d '{"agentId":"agent-2","message":"..."}'`

### Q4: Agent 配置修改后必须重启 Gateway 吗？

**A**: 不需要。OpenClaw Gateway 支持热加载机制，执行 `openclaw gateway reload` 即可应用新配置。Agent workspace 中的文件变更（如修改 `IDENTITY.md`）在下一次请求时自动生效，甚至不需要 reload。

### Q5: 单个 Gateway 最多能管理多少个 Agent？

**A**: 没有硬性上限，但建议根据服务器资源合理规划：
- 4GB 内存：建议 ≤ 5 个 Agent
- 8GB 内存：建议 ≤ 10 个 Agent
- 16GB+ 内存：可支持 15+ 个 Agent

超过 5 个 Agent 时建议启用懒加载模式。使用 `openclaw agents stats` 持续监控资源使用情况。

---

## 8.7 外部参考

- [OpenClaw 官方文档 - 多 Agent 管理](https://docs.openclaw.dev/guides/multi-agent)
- [OpenClaw 官方文档 - Gateway 配置参考](https://docs.openclaw.dev/reference/gateway-config)
- [OpenClaw GitHub - Agent 路由示例](https://github.com/anthropics/openclaw/tree/main/examples/multi-agent)
- [微服务架构中的 Agent 模式（思考参考）](https://martinfowler.com/articles/agent-oriented-architecture.html)
- [飞书机器人开放平台 - 多机器人管理](https://open.feishu.cn/document/home/multiple-bots)

---

## 本章小结

- **单 Gateway 多 Agent 架构** 是 OpenClaw 实现多角色协作和多项目隔离的核心能力。
- **Agent 创建与配置**：每个 Agent 拥有独立的 workspace，包含身份、行为、记忆和技能配置，通过 `openclaw.json` 注册到 Gateway。
- **路由规则**：基于渠道或关键词将请求分发到指定 Agent，支持热加载更新。
- **Agent 间协作**：通过共享记忆目录、消息转发、Cron 定时任务等方式实现跨 Agent 协作流水线。
- **资源管理**：合理设置 `maxConcurrent`、`memoryLimit` 等限制，使用 `openclaw agents stats` 持续监控。
- 遇到问题时，善用 `openclaw doctor` 进行诊断，`openclaw agents list --verbose` 查看详细状态。

---
[⬅️ 上一章：飞书集成与消息自动化](07-飞书集成与消息自动化.md) | [📑 目录](README.md) | [➡️ 下一章：故障排查与日志分析](09-故障排查与日志分析.md)
---
