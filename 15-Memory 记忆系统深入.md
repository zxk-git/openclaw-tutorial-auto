---
[⬅️ 上一章：安全与权限管理](14-安全与权限管理.md) | [📑 目录](README.md) | [➡️ 下一章：MCP 工具协议与自定义集成](16-MCP%20工具协议与自定义集成.md)
---

# 第15章：Memory 记忆系统深入

> **难度**: ⭐⭐⭐ 进阶 | **预计阅读**: 25 分钟 | **前置章节**: [第 1 章](01-基础介绍与安装.md)

> Memory（记忆）系统是 OpenClaw Agent 实现长期学习和个性化服务的核心机制。本章将深入讲解记忆的三种类型、存储格式、管理方法、检索机制和清理策略，帮助你设计出高效的记忆架构，让 Agent 真正具备"经验积累"能力。

## 📑 本章目录

- [15.1 Memory 系统设计](#151-memory-系统设计)
  - [三种记忆类型](#三种记忆类型)
  - [记忆系统架构图](#记忆系统架构图)
  - [记忆生命周期](#记忆生命周期)
- [15.2 记忆存储格式](#152-记忆存储格式)
  - [存储目录结构](#存储目录结构)
  - [Markdown 文件规范](#markdown-文件规范)
  - [MEMORY.md 索引文件](#memorymd-索引文件)
- [15.3 主动记忆管理](#153-主动记忆管理)
  - [创建记忆](#创建记忆)
  - [查询记忆](#查询记忆)
  - [更新记忆](#更新记忆)
  - [删除记忆](#删除记忆)
  - [记忆管理命令速查](#记忆管理命令速查)
- [15.4 记忆命名规范与分类策略](#154-记忆命名规范与分类策略)
  - [命名规范](#命名规范)
  - [分类体系](#分类体系)
  - [标签与元数据](#标签与元数据)
- [15.5 跨会话记忆持久化](#155-跨会话记忆持久化)
  - [会话与记忆的关系](#会话与记忆的关系)
  - [MEMORY.md 的作用](#memorymd-的作用)
  - [持久化流程](#持久化流程)
- [15.6 记忆检索机制](#156-记忆检索机制)
  - [语义匹配](#语义匹配)
  - [关键词检索](#关键词检索)
  - [时间衰减模型](#时间衰减模型)
  - [检索策略对比](#检索策略对比)
- [15.7 记忆合并与清理](#157-记忆合并与清理)
  - [记忆膨胀问题](#记忆膨胀问题)
  - [合并策略](#合并策略)
  - [自动清理规则](#自动清理规则)
  - [手动清理流程](#手动清理流程)
- [15.8 记忆在 Agent 决策中的作用](#158-记忆在-agent-决策中的作用)
  - [决策流程中的记忆注入](#决策流程中的记忆注入)
  - [记忆与 Prompt 的融合](#记忆与-prompt-的融合)
  - [记忆驱动的行为模式](#记忆驱动的行为模式)
- [实操练习](#实操练习)
- [常见问题 (FAQ)](#常见问题-faq)
- [本章小结](#本章小结)

---

## 15.1 Memory 系统设计

### 三种记忆类型

OpenClaw 的记忆系统借鉴认知科学，将记忆分为三种类型：

| 记忆类型 | 英文名 | 存储位置 | 生命周期 | 典型内容 |
|---------|--------|---------|---------|---------|
| 工作记忆 | Working Memory | 会话上下文 | 当前会话 | 对话历史、临时变量、推理中间结果 |
| 短期记忆 | Short-term Memory | `memory/` 目录 | 数天到数周 | 近期任务记录、临时偏好、待办事项 |
| 长期记忆 | Long-term Memory | `memory/` 目录 | 永久 | 用户偏好、技能经验、身份信息、历史决策 |

```text
                   ┌──────────────┐
                   │   用户输入    │
                   └──────┬───────┘
                          │
                   ┌──────▼───────┐
                   │   工作记忆    │  ← 当前对话上下文
                   │  (会话级别)   │
                   └──────┬───────┘
                          │ 提取关键信息
                   ┌──────▼───────┐
                   │   短期记忆    │  ← 近期事件、任务记录
                   │  (天/周级别)  │
                   └──────┬───────┘
                          │ 价值评估 & 固化
                   ┌──────▼───────┐
                   │   长期记忆    │  ← 核心知识、偏好、经验
                   │  (永久存储)   │
                   └──────────────┘
```

### 记忆系统架构图

```text
┌──────────────────────────────────────────────────────────┐
│                    Agent 推理引擎                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐               │
│  │ Prompt   │  │ 工作记忆  │  │ 工具调用  │               │
│  │ Template │←─│ Context  │──│ Results  │               │
│  └────┬─────┘  └──────────┘  └──────────┘               │
│       │                                                   │
│       │  记忆注入                                          │
│       ▼                                                   │
│  ┌─────────────────────────────────────────────────────┐ │
│  │              记忆检索引擎                              │ │
│  │  语义匹配 │ 关键词搜索 │ 时间衰减 │ 相关性排序         │ │
│  └─────────────────────┬───────────────────────────────┘ │
└────────────────────────┼─────────────────────────────────┘
                         │
                ┌────────▼────────┐
                │   记忆存储层     │
                │                 │
                │  ~/.openclaw/   │
                │  workspace/     │
                │  memory/        │
                │  ├─ *.md        │
                │  └─ MEMORY.md   │
                └─────────────────┘
```

### 记忆生命周期

```text
创建 → 存储 → 检索 → 使用 → 更新/合并 → 归档/删除

  ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐
  │  新建   │──▶│ 活跃   │──▶│ 冷却   │──▶│  归档  │
  │ Active │   │ Active │   │ Cool   │   │Archive │
  └────────┘   └───┬────┘   └───┬────┘   └───┬────┘
                   │            │             │
              频繁检索命中    偶尔命中        很少命中
              持续更新       不再更新        可安全删除
```

> [!NOTE]
> 工作记忆随会话结束自动清除。Agent 会在会话结束前自动评估哪些工作记忆值得固化为短期或长期记忆。

---

## 15.2 记忆存储格式

### 存储目录结构

所有持久化记忆文件存储在 `~/.openclaw/workspace/memory/` 目录下：

```bash
# 查看记忆目录
ls -la ~/.openclaw/workspace/memory/
```

```text
total 136
drwxr-xr-x 2 root root 4096 Mar  6 10:00 .
-rw-r--r-- 1 root root  842 Feb 28 10:00 2026-02-28-identity-intro.md
-rw-r--r-- 1 root root 1024 Mar  2 14:00 2026-03-02-xiaohongshu-mcp.md
-rw-r--r-- 1 root root  756 Mar  2 16:00 2026-03-02-xiaohongshu-skill.md
-rw-r--r-- 1 root root  980 Mar  3 09:00 2026-03-03-gongniu-group.md
-rw-r--r-- 1 root root  668 Mar  3 11:00 2026-03-03-openclaw-practice.md
-rw-r--r-- 1 root root  512 Mar  3 14:00 2026-03-03-web-search.md
-rw-r--r-- 1 root root  890 Mar  4 08:00 2026-03-04-memory-merge.md
-rw-r--r-- 1 root root  445 Mar  4 10:00 2026-03-04-memory-sync.md
-rw-r--r-- 1 root root  334 Mar  4 11:00 2026-03-04-memory-timeout.md
...
```

### Markdown 文件规范

每个记忆文件遵循统一的 Markdown 格式：

```markdown
# 记忆标题

> 创建时间: 2026-03-06
> 分类: skill-experience
> 标签: web-search, tavily, api
> 重要性: high
> 状态: active

## 背景

描述触发此记忆的上下文和场景。

## 关键内容

核心要记住的信息，以结构化的方式组织。

## 经验教训

从实践中总结的可复用知识。

## 关联记忆

- [2026-03-02-xiaohongshu-mcp.md](2026-03-02-xiaohongshu-mcp.md) — 相关的 MCP 配置经验
- [2026-03-03-web-search.md](2026-03-03-web-search.md) — Web 搜索配置
```

一个完整的记忆文件示例：

```markdown
# Tavily API 搜索配置经验

> 创建时间: 2026-03-04
> 分类: skill-experience
> 标签: tavily, web-search, api-key, mcp
> 重要性: high
> 状态: active

## 背景

用户需要 Agent 具备 Web 搜索能力。尝试配置 Tavily API 作为
搜索后端，过程中遇到了 API Key 配置和速率限制问题。

## 关键内容

1. Tavily API Key 存放在 `~/.openclaw/credentials/tavily-api-key.json`
2. 免费套餐限制：1000 次/月，5 次/分钟
3. 搜索结果建议使用 `search_depth: "advanced"` 获取更好质量
4. 需要在 Skill 的 `_meta.json` 中声明 `tavily-api-key` 凭证引用

## 经验教训

- API Key 不要硬编码在 SKILL.md 中，应使用 credentials 机制
- 速率限制触发后需等待 60 秒再重试
- `advanced` 深度搜索响应时间约 3-5 秒，注意超时设置

## 关联记忆

- [2026-03-03-web-search.md](2026-03-03-web-search.md)
```

> [!TIP]
> 记忆文件的元数据（创建时间、分类、标签等）使用 Markdown 引用块格式，便于 Agent 解析和人类阅读。

### MEMORY.md 索引文件

`~/.openclaw/workspace/MEMORY.md` 是记忆系统的全局索引文件，Agent 每次启动时首先读取此文件获取记忆概览：

```bash
cat ~/.openclaw/workspace/MEMORY.md
```

```markdown
# Memory 记忆系统

## 记忆索引

当前 memory/ 目录下的记忆文件按分类组织：

### 身份与偏好
- `2026-02-28-identity-intro.md` — 用户身份信息和沟通偏好

### 技能经验
- `2026-03-02-xiaohongshu-mcp.md` — 小红书 MCP 集成经验
- `2026-03-02-xiaohongshu-skill.md` — 小红书 Skill 开发经验
- `2026-03-03-web-search.md` — Web 搜索配置
- `2026-03-04-tavily-key.md` — Tavily API Key 配置

### 系统运维
- `2026-03-04-memory-merge.md` — 记忆合并操作记录
- `2026-03-04-memory-sync.md` — 记忆同步策略
- `2026-03-04-memory-timeout.md` — 记忆超时处理

### 任务记录
- `2026-03-03-gongniu-group.md` — 公牛集团相关任务
- `2026-03-04-resume-autodelivery.md` — 简历自动投递任务

## 记忆规则

1. 每条记忆使用独立的 Markdown 文件
2. 文件名格式：`YYYY-MM-DD-topic.md`
3. 文件头部包含元数据（分类、标签、重要性）
4. 定期合并相关记忆，避免文件过多
5. 不再有用的记忆及时归档或删除
```

---

## 15.3 主动记忆管理

### 创建记忆

Agent 可以主动创建记忆文件，也可以由用户指示创建：

```bash
# 方式 1：直接创建记忆文件
cat > ~/.openclaw/workspace/memory/2026-03-06-security-config.md << 'EOF'
# 安全配置经验总结

> 创建时间: 2026-03-06
> 分类: system-ops
> 标签: security, exec-approvals, permissions
> 重要性: high
> 状态: active

## 关键内容

1. exec-approvals.json 的默认策略建议设为 "prompt"
2. 危险命令（rm -rf, mkfs 等）应设为 "deny"
3. Git 只读操作可安全设为 "allow"
4. 新安装的 Skill 默认使用 "standard" 沙箱模式

## 经验教训

- 先从严格模式开始，逐步放宽权限
- 变更安全配置前一定要备份
- 定期查看审计日志发现异常
EOF
```

```bash
# 方式 2：通过 Agent 对话创建（在与 Agent 交互时）
# 用户输入："请记住以下信息——我的 GitHub 用户名是 zxk，
#            主要仓库在 github.com/zxk/openclaw-tutorial-auto"
# Agent 会自动创建对应的记忆文件
```

### 查询记忆

```bash
# 按关键词搜索记忆
grep -rl "tavily" ~/.openclaw/workspace/memory/

# 按分类搜索
grep -l "分类: skill-experience" ~/.openclaw/workspace/memory/*.md

# 按标签搜索
grep -l "标签:.*security" ~/.openclaw/workspace/memory/*.md

# 按日期范围搜索（2026年3月的所有记忆）
ls ~/.openclaw/workspace/memory/2026-03-*.md

# 搜索高重要性记忆
grep -l "重要性: high" ~/.openclaw/workspace/memory/*.md
```

### 更新记忆

```bash
# 追加内容到已有记忆
cat >> ~/.openclaw/workspace/memory/2026-03-06-security-config.md << 'EOF'

## 更新记录

### 2026-03-06 补充
- 发现 Vault 集成需要额外配置 VAULT_TOKEN 环境变量
- 凭证加密使用 AES-256-GCM 算法，密钥派生自设备指纹
EOF
```

```bash
# 修改记忆状态（将短期记忆升级为长期记忆）
sed -i 's/> 状态: active/> 状态: permanent/' \
  ~/.openclaw/workspace/memory/2026-03-06-security-config.md
```

### 删除记忆

```bash
# 直接删除（不可恢复）
rm ~/.openclaw/workspace/memory/2026-01-15-obsolete-info.md

# 安全删除（先归档再删除）
mkdir -p ~/.openclaw/workspace/memory/archive/
mv ~/.openclaw/workspace/memory/2026-01-15-obsolete-info.md \
   ~/.openclaw/workspace/memory/archive/

# 批量归档过期记忆
find ~/.openclaw/workspace/memory/ -name "*.md" -mtime +30 \
  -exec grep -l "重要性: low" {} \; | while read f; do
    mv "$f" ~/.openclaw/workspace/memory/archive/
    echo "已归档: $(basename $f)"
done
```

### 记忆管理命令速查

| 操作 | 命令 | 说明 |
|------|------|------|
| 创建 | 直接写入 `.md` 文件 | 遵循命名规范和格式规范 |
| 查询 | `grep -rl "keyword" memory/` | 支持关键词、标签、分类搜索 |
| 更新 | 编辑 `.md` 文件内容 | 追加更新记录，保留历史 |
| 删除 | `rm` 或 `mv` 到 `archive/` | 建议先归档再删除 |
| 统计 | `ls memory/*.md \| wc -l` | 统计记忆文件数量 |
| 全览 | `cat MEMORY.md` | 查看记忆索引 |

---

## 15.4 记忆命名规范与分类策略

### 命名规范

记忆文件名采用 `YYYY-MM-DD-topic.md` 格式：

```text
格式：YYYY-MM-DD-<topic-slug>.md

规则：
  ├─ 日期部分：记忆创建日期（ISO 8601）
  ├─ 主题部分：用英文短横线连接的关键词
  ├─ 全部小写
  ├─ 避免特殊字符（仅 a-z, 0-9, -）
  └─ 后缀：.md

正确示例：
  ✅ 2026-03-06-tavily-api-config.md
  ✅ 2026-03-05-hubei-job-scrape.md
  ✅ 2026-02-28-identity-intro.md

错误示例：
  ❌ tavily配置.md          （中文、无日期）
  ❌ 2026-3-6-config.md     （月份未补零）
  ❌ 2026-03-06_Config.md   （下划线、大写）
  ❌ memory-2026-03-06.md   （日期不在开头）
```

### 分类体系

建议将记忆分为以下核心分类：

| 分类标识 | 中文名 | 说明 | 示例 |
|---------|--------|------|------|
| `identity` | 身份信息 | 用户画像、偏好设置 | 用户名、沟通风格、语言偏好 |
| `skill-experience` | 技能经验 | Skill 使用和开发经验 | API 配置技巧、错误处理方法 |
| `task-record` | 任务记录 | 具体任务执行记录 | 投递简历、生成报告 |
| `system-ops` | 系统运维 | 系统配置和维护记录 | 安全配置、性能调优 |
| `knowledge` | 知识积累 | 领域知识和学习笔记 | 技术概念、行业信息 |
| `decision-log` | 决策日志 | 重要决策的过程记录 | 方案选型、技术决策理由 |

```bash
# 按分类统计记忆文件数量
for category in identity skill-experience task-record system-ops knowledge decision-log; do
  count=$(grep -l "分类: $category" ~/.openclaw/workspace/memory/*.md 2>/dev/null | wc -l)
  printf "%-20s %d 条\n" "$category" "$count"
done
```

### 标签与元数据

标签用于跨分类的细粒度检索：

```markdown
> 标签: web-search, tavily, api-key, rate-limit
```

```bash
# 提取所有使用过的标签及其频率
grep "^> 标签:" ~/.openclaw/workspace/memory/*.md | \
  sed 's/.*标签: //' | tr ',' '\n' | sed 's/^ //' | \
  sort | uniq -c | sort -rn | head -20
```

```text
   8  security
   6  mcp
   5  web-search
   5  skill
   4  api-key
   3  feishu
   3  automation
   2  tavily
   2  memory
   1  vault
```

> [!TIP]
> 标签应使用英文小写，用逗号分隔。建议维护一个标签词典，避免同义不同标签（如 `web-search` 和 `search-web`）。

---

## 15.5 跨会话记忆持久化

### 会话与记忆的关系

```text
会话 1                    会话 2                    会话 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ 工作记忆  │             │ 工作记忆  │             │ 工作记忆  │
│(会话结束  │             │(加载持久  │             │(加载持久  │
│ 时评估)   │             │ 化记忆)   │             │ 化记忆)   │
└────┬─────┘             └────┬─────┘             └────┬─────┘
     │ 固化                  │ 固化                   │ 固化
     ▼                       ▼                        ▼
┌─────────────────────────────────────────────────────────┐
│               持久化记忆存储 (memory/*.md)                │
│                                                          │
│  记忆 A ─── 记忆 B ─── 记忆 C ─── 记忆 D ─── 记忆 E    │
│  (会话1)    (会话1)    (会话2)    (会话2)    (会话3)      │
└─────────────────────────────────────────────────────────┘
```

### MEMORY.md 的作用

`MEMORY.md` 是 Agent 的"记忆地图"。每次新会话启动时，Agent 按以下顺序加载上下文：

```text
1. 读取 IDENTITY.md     → 了解自己的身份和角色
2. 读取 USER.md         → 了解用户信息和偏好
3. 读取 MEMORY.md       → 获取记忆索引和检索入口
4. 读取 SOUL.md         → 加载行为准则和价值观
5. 按需检索 memory/*.md → 根据当前任务加载相关记忆
```

```bash
# 查看 Agent 启动时加载的文件
ls -la ~/.openclaw/workspace/{IDENTITY,USER,MEMORY,SOUL}.md
```

> [!NOTE]
> `MEMORY.md` 不存储记忆本身，而是作为索引和导航。Agent 根据当前任务的上下文，从索引中选择相关记忆文件深入读取。

### 持久化流程

当 Agent 判断某个信息值得长期保存时，会自动执行以下流程：

```text
Step 1: 价值评估
  Agent 判断信息是否满足持久化条件：
  - 是否是新的、未知的信息？
  - 是否可能在未来任务中复用？
  - 用户是否明确要求记住？

Step 2: 格式化
  将信息转换为标准记忆格式：
  - 生成文件名（YYYY-MM-DD-topic.md）
  - 填写元数据（分类、标签、重要性）
  - 组织内容结构

Step 3: 写入
  创建记忆文件：
  - 写入 memory/ 目录
  - 更新 MEMORY.md 索引

Step 4: 确认
  通知用户记忆已保存：
  - "我已记住这个信息，保存在 memory/2026-03-06-xxx.md"
```

```bash
# 模拟 Agent 创建记忆的完整流程
TOPIC="docker-deploy-tips"
DATE=$(date +%Y-%m-%d)
FILE="~/.openclaw/workspace/memory/${DATE}-${TOPIC}.md"

# 创建记忆文件
cat > "$FILE" << 'EOF'
# Docker 部署经验

> 创建时间: 2026-03-06
> 分类: system-ops
> 标签: docker, deploy, tips
> 重要性: medium
> 状态: active

## 关键内容

- OpenClaw 容器建议使用 `--restart=unless-stopped` 策略
- 数据目录 `~/.openclaw/` 应挂载为 Docker Volume
- 容器内的 Agent 会话日志存储在 `/root/.openclaw/agents/`
EOF

# 更新 MEMORY.md 索引（追加条目）
echo "- \`${DATE}-${TOPIC}.md\` — Docker 部署实践经验" >> \
  ~/.openclaw/workspace/MEMORY.md

echo "✅ 记忆已创建并更新索引"
```

---

## 15.6 记忆检索机制

### 语义匹配

Agent 在处理用户请求时，会将请求语义与记忆内容进行匹配：

```text
用户请求："帮我配置 Web 搜索功能"

语义匹配过程：
  1. 提取关键概念：[Web 搜索, 配置, 功能]
  2. 扫描 MEMORY.md 索引中的关键词
  3. 匹配到候选记忆：
     - 2026-03-03-web-search.md        (相关度: 0.95)
     - 2026-03-04-tavily-key.md         (相关度: 0.88)
     - 2026-03-02-xiaohongshu-mcp.md    (相关度: 0.42)
  4. 加载相关度 > 0.5 的记忆文件
  5. 将记忆内容注入到推理上下文
```

### 关键词检索

当语义匹配不够精确时，Agent 会回退到关键词检索：

```bash
# Agent 内部执行的检索逻辑（等效命令）
grep -rl "web.*search\|搜索.*配置\|tavily" \
  ~/.openclaw/workspace/memory/*.md | \
  head -5
```

### 时间衰减模型

记忆的"新鲜度"随时间递减，影响检索优先级：

```text
新鲜度公式：freshness = e^(-λ × days_since_creation)

其中 λ（衰减系数）取决于记忆重要性：
  - high:   λ = 0.005  （衰减很慢，200天后仍有 37% 新鲜度）
  - medium: λ = 0.02   （衰减适中，50天后仍有 37%）
  - low:    λ = 0.05   （衰减较快，20天后仍有 37%）
```

| 记忆重要性 | 1天后 | 7天后 | 30天后 | 90天后 | 365天后 |
|-----------|-------|-------|--------|--------|---------|
| high | 99.5% | 96.5% | 86.1% | 63.8% | 16.1% |
| medium | 98.0% | 86.9% | 54.9% | 16.5% | 0.1% |
| low | 95.1% | 70.5% | 22.3% | 1.1% | ~0% |

> [!NOTE]
> 时间衰减不会自动删除记忆，只是降低检索排序权重。低新鲜度的记忆仍然可以被精确关键词搜索命中。

### 检索策略对比

| 策略 | 优势 | 劣势 | 适用场景 |
|------|------|------|---------|
| 语义匹配 | 理解意图、模糊匹配 | 计算开销大、可能误匹配 | 开放性问题、探索性任务 |
| 关键词检索 | 精确、快速 | 不理解同义词 | 精确查找、技术术语 |
| 时间衰减 | 优先返回新鲜信息 | 可能遗漏久远但重要的记忆 | 动态变化的信息 |
| 混合策略 | 综合优势 | 实现复杂 | **默认推荐** |

---

## 15.7 记忆合并与清理

### 记忆膨胀问题

随着 Agent 持续运行，记忆文件会不断增长：

```bash
# 诊断记忆膨胀
echo "=== 记忆系统健康检查 ==="
echo "文件总数: $(ls ~/.openclaw/workspace/memory/*.md 2>/dev/null | wc -l)"
echo "总大小: $(du -sh ~/.openclaw/workspace/memory/ | cut -f1)"
echo "最大文件: $(ls -lS ~/.openclaw/workspace/memory/*.md | head -1 | awk '{print $5, $NF}')"
echo "最旧文件: $(ls -lt ~/.openclaw/workspace/memory/*.md | tail -1 | awk '{print $6,$7,$8, $NF}')"
echo "本周新增: $(find ~/.openclaw/workspace/memory/ -name '*.md' -mtime -7 | wc -l)"
```

膨胀警戒线：

| 指标 | 健康 | 注意 | 警告 | 危险 |
|------|-----|------|------|------|
| 文件数量 | < 50 | 50-100 | 100-200 | > 200 |
| 总大小 | < 500KB | 500KB-2MB | 2MB-10MB | > 10MB |
| 单文件大小 | < 5KB | 5-20KB | 20-50KB | > 50KB |

> [!WARNING]
> 记忆文件过多会拖慢 Agent 的上下文加载速度。当文件超过 100 个时，建议立即进行合并清理。

### 合并策略

将相关的多个记忆合并为一个综合性文件：

```bash
# 示例：合并所有 web-search 相关的记忆
# 步骤 1：找出相关文件
grep -l "标签:.*web-search" ~/.openclaw/workspace/memory/*.md
```

```text
2026-03-03-web-search.md
2026-03-04-tavily-key.md
2026-03-05-search-optimization.md
```

```bash
# 步骤 2：创建合并后的文件
cat > ~/.openclaw/workspace/memory/2026-03-06-web-search-consolidated.md << 'EOF'
# Web 搜索能力综合经验

> 创建时间: 2026-03-06
> 分类: skill-experience
> 标签: web-search, tavily, search, consolidated
> 重要性: high
> 状态: active
> 合并来源: 2026-03-03-web-search.md, 2026-03-04-tavily-key.md,
>           2026-03-05-search-optimization.md

## Tavily API 配置

- API Key 存放在 credentials/tavily-api-key.json
- 免费套餐：1000次/月，5次/分钟
- 推荐使用 search_depth: "advanced"

## 搜索优化技巧

- 使用具体的关键词而非长句
- 中英文混合搜索效果更好
- 对结果进行二次过滤和摘要

## 常见问题处理

- 429 错误：等待 60 秒重试
- 超时：advanced 模式建议设置 10s 超时
- 空结果：尝试简化查询或更换搜索引擎
EOF

# 步骤 3：归档旧文件
mkdir -p ~/.openclaw/workspace/memory/archive/
mv ~/.openclaw/workspace/memory/2026-03-03-web-search.md \
   ~/.openclaw/workspace/memory/archive/
mv ~/.openclaw/workspace/memory/2026-03-04-tavily-key.md \
   ~/.openclaw/workspace/memory/archive/
mv ~/.openclaw/workspace/memory/2026-03-05-search-optimization.md \
   ~/.openclaw/workspace/memory/archive/

# 步骤 4：更新 MEMORY.md 索引
echo "✅ 记忆合并完成，3 个文件合并为 1 个"
```

### 自动清理规则

可以配置定期清理策略：

```yaml
# cron/jobs.json 中的记忆清理任务
{
  "name": "memory-cleanup",
  "schedule": "0 3 * * 0",
  "prompt": |
    请执行记忆系统清理：
    1. 统计 memory/ 目录下的文件数量和大小
    2. 找出重要性为 low 且超过 30 天的记忆，移到 archive/
    3. 找出同分类下超过 5 个文件的分类，建议合并
    4. 更新 MEMORY.md 索引
    5. 输出清理报告
}
```

### 手动清理流程

```bash
# 完整的手动清理流程

# 1. 评估当前状态
echo "=== 清理前状态 ==="
ls ~/.openclaw/workspace/memory/*.md | wc -l
du -sh ~/.openclaw/workspace/memory/

# 2. 找出可安全清理的文件
echo "=== 低重要性 + 30天以上 ==="
find ~/.openclaw/workspace/memory/ -name "*.md" -mtime +30 \
  -exec grep -l "重要性: low" {} \;

# 3. 找出可合并的文件（同分类）
echo "=== 分类文件数统计 ==="
grep -h "^> 分类:" ~/.openclaw/workspace/memory/*.md 2>/dev/null | \
  sort | uniq -c | sort -rn

# 4. 执行归档
mkdir -p ~/.openclaw/workspace/memory/archive/
# ... 移动文件 ...

# 5. 验证清理结果
echo "=== 清理后状态 ==="
ls ~/.openclaw/workspace/memory/*.md | wc -l
du -sh ~/.openclaw/workspace/memory/
```

---

## 15.8 记忆在 Agent 决策中的作用

### 决策流程中的记忆注入

Agent 在处理每一个请求时，都会经历以下记忆参与的决策流程：

```text
┌──────────────┐
│  用户请求     │
└──────┬───────┘
       │
┌──────▼───────┐      ┌─────────────────┐
│  意图识别     │─────▶│  记忆检索        │
│  (理解需求)   │      │  (查找相关经验)  │
└──────┬───────┘      └────────┬────────┘
       │                       │
       │  ┌────────────────────┘
       │  │ 注入相关记忆
┌──────▼──▼────┐
│  方案规划     │  ← 结合记忆中的经验制定方案
│  (制定计划)   │
└──────┬───────┘
       │
┌──────▼───────┐
│  执行方案     │  ← 避免重复过去的错误
│  (工具调用)   │
└──────┬───────┘
       │
┌──────▼───────┐
│  结果评估     │  ← 与记忆中的预期对比
│  (回顾验证)   │
└──────┬───────┘
       │
┌──────▼───────┐
│  记忆更新     │  ← 将新经验写入记忆
│  (经验沉淀)   │
└──────────────┘
```

### 记忆与 Prompt 的融合

Agent 在构造 Prompt 时，会将检索到的记忆嵌入上下文：

```text
System Prompt（简化示意）:

你是 OpenClaw Agent，以下是你的相关记忆：

--- 记忆开始 ---
[来自 2026-03-04-tavily-key.md]
- Tavily API 免费套餐限制：1000次/月，5次/分钟
- 搜索建议使用 search_depth: "advanced"
- 速率限制触发后需等待 60 秒

[来自 2026-02-28-identity-intro.md]
- 用户偏好语言：中文
- 沟通风格：简洁直接
--- 记忆结束 ---

请根据以上记忆和当前对话处理用户请求。
```

### 记忆驱动的行为模式

长期记忆会显著影响 Agent 的行为方式：

| 记忆类型 | 行为影响 | 示例 |
|---------|---------|------|
| 用户偏好 | 调整回复风格 | 记住用户喜欢简洁回答，减少冗长解释 |
| 错误经验 | 避免重复错误 | 记住某 API 的速率限制，主动控制调用频率 |
| 成功经验 | 复用有效方案 | 记住某个任务的最佳执行路径，直接复用 |
| 工具偏好 | 选择合适工具 | 记住用户倾向使用 Tavily 而非 DuckDuckGo |
| 时间模式 | 适应工作节奏 | 记住用户通常在上午处理技术任务 |

> [!TIP]
> 记忆的质量直接决定 Agent 的智能程度。高质量的记忆应该是：**具体的**（包含操作细节）、**结构化的**（分类清晰）、**可复用的**（提炼为通用经验）。

---

## 实操练习

以下练习帮助你掌握 Memory 系统的核心操作。请按顺序完成。

### 练习 1：查看现有记忆系统

**目标**：了解当前环境中的记忆状态。

```bash
# 步骤 1：查看 MEMORY.md 索引
cat ~/.openclaw/workspace/MEMORY.md

# 步骤 2：统计记忆文件
echo "文件数量: $(ls ~/.openclaw/workspace/memory/*.md | wc -l)"
echo "总大小: $(du -sh ~/.openclaw/workspace/memory/ | cut -f1)"

# 步骤 3：查看最新的 3 条记忆
ls -lt ~/.openclaw/workspace/memory/*.md | head -3

# 步骤 4：读取一条记忆的内容
head -20 ~/.openclaw/workspace/memory/$(ls -t ~/.openclaw/workspace/memory/ | head -1)
```

### 练习 2：创建结构化记忆

**目标**：按照规范创建一条完整的记忆文件。

```bash
# 步骤 1：确定记忆主题和内容
TOPIC="memory-system-practice"
DATE=$(date +%Y-%m-%d)

# 步骤 2：创建记忆文件
cat > ~/.openclaw/workspace/memory/${DATE}-${TOPIC}.md << 'EOF'
# Memory 系统学习笔记

> 创建时间: 2026-03-06
> 分类: knowledge
> 标签: memory, learning, openclaw
> 重要性: medium
> 状态: active

## 关键内容

1. OpenClaw 记忆分为三种类型：工作记忆、短期记忆、长期记忆
2. 记忆文件命名格式：YYYY-MM-DD-topic.md
3. MEMORY.md 是记忆系统的全局索引
4. 记忆检索使用语义匹配 + 关键词 + 时间衰减的混合策略
5. 定期合并清理防止记忆膨胀

## 实践体会

- 创建记忆时分类和标签要认真填写，影响后续检索效率
- 高重要性记忆衰减慢，适合存储核心知识
- 合并策略能有效控制文件数量
EOF

# 步骤 3：验证文件格式
echo "=== 元数据检查 ==="
head -7 ~/.openclaw/workspace/memory/${DATE}-${TOPIC}.md

# 步骤 4：检查文件名规范
echo "=== 文件名: ${DATE}-${TOPIC}.md ==="
[[ "${DATE}-${TOPIC}.md" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+\.md$ ]] && \
  echo "✅ 文件名格式正确" || echo "❌ 文件名格式不正确"
```

### 练习 3：记忆检索练习

**目标**：练习多种记忆检索方式。

```bash
# 方式 1：关键词搜索
echo "=== 搜索包含 'mcp' 的记忆 ==="
grep -rl "mcp" ~/.openclaw/workspace/memory/*.md

# 方式 2：按分类搜索
echo "=== 搜索 skill-experience 分类 ==="
grep -l "分类: skill-experience" ~/.openclaw/workspace/memory/*.md

# 方式 3：按时间搜索（最近 7 天）
echo "=== 最近 7 天的记忆 ==="
find ~/.openclaw/workspace/memory/ -name "*.md" -mtime -7 -printf "%T+ %p\n" | sort -r

# 方式 4：按重要性搜索
echo "=== 高重要性记忆 ==="
grep -l "重要性: high" ~/.openclaw/workspace/memory/*.md

# 方式 5：多条件组合搜索
echo "=== 高重要性 + 包含 api ==="
grep -l "重要性: high" ~/.openclaw/workspace/memory/*.md | \
  xargs grep -l "api" 2>/dev/null
```

### 练习 4：记忆合并与清理

**目标**：实践记忆的合并归档流程。

```bash
# 步骤 1：诊断当前状态
echo "=== 记忆系统诊断 ==="
echo "文件总数: $(ls ~/.openclaw/workspace/memory/*.md 2>/dev/null | wc -l)"
echo ""
echo "=== 按分类统计 ==="
grep -h "^> 分类:" ~/.openclaw/workspace/memory/*.md 2>/dev/null | \
  sort | uniq -c | sort -rn

# 步骤 2：找出分类文件数超过 3 个的候选合并目标
echo ""
echo "=== 建议合并的分类 ==="
grep -h "^> 分类:" ~/.openclaw/workspace/memory/*.md 2>/dev/null | \
  sort | uniq -c | sort -rn | awk '$1 > 3 {print $0, " ← 建议合并"}'

# 步骤 3：创建归档目录（如果不存在）
mkdir -p ~/.openclaw/workspace/memory/archive/

# 步骤 4：在 Agent 对话中请求自动合并
# 输入："请检查 memory/ 目录，找出可以合并的相关记忆，
#        执行合并并更新 MEMORY.md 索引"
```

---

## 常见问题 (FAQ)

### Q1：Agent 是否会自动创建记忆？

**A**：是的。Agent 会在以下情况自动创建记忆：
- 用户明确要求"记住"某个信息
- 任务执行中发现了值得记录的经验教训
- 用户偏好或习惯发生变化

你也可以在 `SOUL.md` 中配置 Agent 的记忆创建策略。

### Q2：记忆文件可以手动编辑吗？

**A**：完全可以。记忆文件就是普通的 Markdown 文件，你可以随时手动编辑、创建或删除：

```bash
# 直接编辑记忆文件
vim ~/.openclaw/workspace/memory/2026-03-06-my-memory.md

# 编辑后 Agent 会在下次读取时获取更新内容
```

### Q3：如何防止 Agent 记住错误的信息？

**A**：定期审查记忆文件，或者明确告诉 Agent：

```text
# 在对话中纠正记忆
"请更新记忆：之前记录的 Tavily 速率限制是每分钟5次是错的，
 应该是每分钟10次。请修改相关的记忆文件。"
```

### Q4：记忆系统占用多少存储空间？

**A**：通常很小。50 个记忆文件约 200-500KB。即使达到 200 个文件，也不会超过 5MB。主要瓶颈是 Agent 加载上下文的速度，而非磁盘空间。

---

## 本章小结

- **三种记忆**：工作记忆（会话级）、短期记忆（天/周级）、长期记忆（永久），从临时到持久逐级沉淀。
- **存储格式**：使用结构化 Markdown 文件，统一命名规范 `YYYY-MM-DD-topic.md`，包含元数据头部。
- **MEMORY.md**：记忆系统的全局索引，Agent 每次启动时首先读取，是记忆检索的入口。
- **检索机制**：语义匹配 + 关键词 + 时间衰减的混合策略，平衡准确性和新鲜度。
- **合并清理**：定期监控记忆膨胀指标，通过合并同类记忆和归档低价值记忆保持系统健康。
- **决策驱动**：记忆直接影响 Agent 的方案规划、错误规避和行为风格，是智能化的核心。

---
[⬅️ 上一章：安全与权限管理](14-安全与权限管理.md) | [📑 目录](README.md) | [➡️ 下一章：MCP 工具协议与自定义集成](16-MCP%20工具协议与自定义集成.md)
---
