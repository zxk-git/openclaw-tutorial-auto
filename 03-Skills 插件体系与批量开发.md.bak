---
[⬅️ 上一章：部署与环境初始化](02-部署与环境初始化.md) | [📑 目录](README.md) | [➡️ 下一章：Skills 安装与管理实践](04-Skills%20安装与管理实践.md)
---

# 第3章：Skills 插件体系与批量开发

> **难度**: ⭐⭐ 中级 | **预计阅读**: 20 分钟 | **前置章节**: [第 1-2 章](01-基础介绍与安装.md)

> 本章深入讲解 OpenClaw 的 Skills 插件体系——它是平台最核心的扩展机制。通过 Skills，Agent 可以获得搜索、办公集成、安全审查等各种能力。你将学会如何理解 Skill 结构、编写自己的 SKILL.md 并进行批量开发。

---

## 📑 目录

- [3.1 Skills 插件体系概述](#31-skills-插件体系概述)
- [3.2 Skill 目录结构](#32-skill-目录结构)
- [3.3 SKILL.md 编写规范](#33-skillmd-编写规范)
- [3.4 Skill 开发实战](#34-skill-开发实战)
- [3.5 批量 Skill 管理](#35-批量-skill-管理)
- [3.6 调试与测试](#36-调试与测试)
- [实操练习](#实操练习)
- [常见问题 (FAQ)](#常见问题-faq)
- [外部参考链接](#外部参考链接)
- [本章小结](#本章小结)

---

## 3.1 Skills 插件体系概述

OpenClaw 的 Skills 插件体系是平台的灵魂。每个 Skill 是一个独立目录，包含描述文件（SKILL.md）、元数据（_meta.json）、脚本和配置。

Agent 在运行时会自动加载 `~/.openclaw/workspace/skills/` 目录下的所有已安装 Skills，根据触发词或用户意图匹配合适的技能并调用。

### Skills 体系架构

```text
Agent 接收用户请求
    ↓
意图识别 → 匹配 Skill 触发词
    ↓
加载 SKILL.md → 解析指令/脚本/工具
    ↓
执行 Skill 逻辑（shell/python/MCP 等）
    ↓
返回结果给用户
```

### 当前内置分类

| 分类 | 数量 | 示例技能 | 典型使用场景 |
|------|------|---------|-------------|
| 搜索引擎 | 5 | tavily-search, ddg-web-search, multi-search-engine | 联网搜索、信息检索 |
| Agent 框架 | 2 | proactive-agent, self-improving-agent | 主动执行、自我优化 |
| 办公集成 | 2 | gog (Google Workspace), notion | 文档协作、笔记管理 |
| 文件工具 | 2 | file-search, markdown-converter | 文件搜索、格式转换 |
| 任务自动化 | 1 | complex-task-automator | 多步骤工作流编排 |
| 安全审查 | 1 | skill-vetter | Skill 安全性扫描 |
| MCP 集成 | 1 | McPorter | MCP 服务器管理 |
| 记忆系统 | 1 | memory | 长期记忆存储与检索 |

---

## 3.2 Skill 目录结构

每个 Skill 遵循统一的目录规范：

```text
~/.openclaw/workspace/skills/<skill-name>/
├── SKILL.md          # 核心：技能描述与使用说明（必需）
├── _meta.json        # 元数据（安装源、版本等）
├── scripts/          # 可执行脚本
│   ├── search.mjs    # Node.js 脚本示例
│   └── core/         # Python 核心模块
├── templates/        # 配置模板
├── examples/         # 使用示例
└── hooks/            # 钩子脚本（可选）
```

### 关键文件说明

**SKILL.md** — 技能的入口文件，采用 YAML frontmatter + Markdown 正文：

```markdown
---
name: my-skill
version: 1.0.0
description: "技能的简短描述"
author: your-name
metadata:
  tags: [search, ai]
  triggers:
    - "搜索"
    - "查找"
---
# My Skill
正文说明如何使用此技能...
```

**_meta.json** — 安装元数据：

```json
{
  "name": "my-skill",
  "version": "1.0.0",
  "source": "clawdhub",
  "installedAt": "2026-03-01T00:00:00Z"
}
```

### 文件作用速查表

| 文件/目录 | 是否必需 | 作用 | Agent 使用方式 |
|-----------|---------|------|---------------|
| SKILL.md | ✅ 必需 | 技能入口与使用说明 | 解析 frontmatter + 正文指令 |
| _meta.json | ✅ 必需 | 安装元数据 | 版本检查、来源追踪 |
| scripts/ | 可选 | 可执行脚本 | 按 SKILL.md 指令调用 |
| templates/ | 可选 | 配置模板 | 初始化时使用 |
| hooks/ | 可选 | 生命周期钩子 | 安装/卸载时触发 |

---

## 3.3 SKILL.md 编写规范

SKILL.md 是 Agent 理解和使用技能的唯一入口。编写质量直接影响技能的可用性。

### Frontmatter 字段

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `name` | string | ✅ | 技能唯一标识符 |
| `version` | string | ✅ | 语义化版本号 |
| `description` | string | ✅ | 简短描述（一行） |
| `author` | string | ✅ | 作者名称 |
| `metadata.tags` | list | - | 分类标签 |
| `metadata.triggers` | list | - | 触发关键词 |

### 正文结构建议

```markdown
# Skill Name
一句话说明用途。

## 快速开始
最小示例...

## 使用方法
### 命令/工具列表
详细 API 或命令...

## 配置
环境变量/参数...

## 依赖
- 系统要求: xxx
- 环境变量: xxx
```

### 编写技巧

- **触发词要准确**：避免过于宽泛（如"帮我"），应使用明确的动作词
- **示例要可运行**：给出完整的命令行示例
- **错误处理要说明**：列出常见错误及解决方法
- **依赖要声明**：明确需要哪些外部工具（如 `node`, `python3` 等）

### 编写质量检查清单

在提交 SKILL.md 前，逐项检查：

```bash
# 1. 验证 YAML frontmatter 格式
python3 -c "
import yaml, sys
with open('SKILL.md') as f:
    parts = f.read().split('---')
    if len(parts) >= 3:
        meta = yaml.safe_load(parts[1])
        required = ['name', 'version', 'description', 'author']
        missing = [k for k in required if k not in meta]
        if missing:
            print(f'❌ 缺少必填字段: {missing}')
            sys.exit(1)
        print(f'✅ frontmatter 有效: {meta[\"name\"]} v{meta[\"version\"]}')
"

# 2. 检查是否包含使用示例
grep -c '```' SKILL.md && echo "✅ 包含代码示例" || echo "⚠️ 建议添加代码示例"

# 3. 检查触发词是否定义
grep -q 'triggers' SKILL.md && echo "✅ 已定义触发词" || echo "⚠️ 建议添加触发词"
```

---

## 3.4 Skill 开发实战

以创建一个简单的天气查询 Skill 为例，展示完整开发流程。

### Step 1：创建目录

```bash
mkdir -p ~/.openclaw/workspace/skills/weather-check
cd ~/.openclaw/workspace/skills/weather-check
```

### Step 2：编写 SKILL.md

```markdown
---
name: weather-check
version: 1.0.0
description: "查询指定城市的天气情况"
author: demo
metadata:
  tags: [weather, utility]
  triggers:
    - "天气"
    - "weather"
---
# Weather Check
查询指定城市的当前天气。

## 使用方法
\```bash
curl -s "https://wttr.in/Beijing?format=3"
\```

## 示例
- 查询北京天气: `curl -s "https://wttr.in/Beijing?format=3"`
- 查询上海天气: `curl -s "https://wttr.in/Shanghai?format=3"`
```

### Step 3：创建元数据文件

```bash
cat > _meta.json << 'EOF'
{
  "name": "weather-check",
  "version": "1.0.0",
  "source": "local",
  "installedAt": "2026-03-06T00:00:00Z"
}
EOF
```

### Step 4：测试运行

```bash
# 直接运行 Skill 中的命令
curl -s "https://wttr.in/Beijing?format=3"
# 输出: Beijing: ⛅️  +22°C

# 测试多个城市
for city in Beijing Shanghai Wuhan; do
  echo -n "$city: "
  curl -s "https://wttr.in/$city?format=3"
done
```

### Step 5：验证注册

将 Skill 放入 `~/.openclaw/workspace/skills/` 后，Agent 会在下次会话中自动加载。

```bash
# 验证 Skill 目录结构完整性
ls -la ~/.openclaw/workspace/skills/weather-check/
# 预期输出: SKILL.md  _meta.json

# 使用 doctor 检查加载状态
openclaw doctor
```

---

## 3.5 批量 Skill 管理

当拥有多个 Skills 时，需要高效的批量管理方法。

### 列出已安装 Skills

```bash
ls -la ~/.openclaw/workspace/skills/
# 或使用 find-skills 工具
npx skills check
```

### 批量操作脚本

```bash
#!/bin/bash
# list-skills.sh — 列出所有 Skill 及其版本
for skill_dir in ~/.openclaw/workspace/skills/*/; do
  skill_name=$(basename "$skill_dir")
  if [ -f "$skill_dir/SKILL.md" ]; then
    version=$(grep -oP 'version:\s*\K[\d.]+' "$skill_dir/SKILL.md" | head -1)
    echo "$skill_name: v${version:-unknown}"
  fi
done
```

### 批量健康检查脚本

```bash
#!/bin/bash
# check-skills.sh — 批量验证所有 Skill 的完整性
PASS=0; FAIL=0
for skill_dir in ~/.openclaw/workspace/skills/*/; do
  name=$(basename "$skill_dir")
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo "❌ $name: 缺少 SKILL.md"
    ((FAIL++))
  elif [ ! -f "$skill_dir/_meta.json" ]; then
    echo "⚠️  $name: 缺少 _meta.json"
    ((FAIL++))
  else
    echo "✅ $name"
    ((PASS++))
  fi
done
echo "---"
echo "通过: $PASS  失败: $FAIL  总计: $((PASS+FAIL))"
```

### 批量更新

```bash
npx skills update  # 检查并更新所有已安装 Skills
```

### Skill 禁用与启用

在 `~/.openclaw/openclaw.json` 中控制：

```json
{
  "skills": {
    "entries": {
      "tavily": { "enabled": true },
      "ddg-search": { "enabled": false }
    }
  }
}
```

---

## 3.6 调试与测试

开发 Skills 时的调试方法和测试策略。

### 查看 Skill 加载状态

```bash
openclaw doctor  # 包含 Skills 加载检测
```

### 常见调试方式

1. **直接执行脚本**：测试 Skill 中的脚本能否独立运行
```bash
node ~/.openclaw/workspace/skills/tavily-search/scripts/search.mjs "test query"
```

2. **检查 YAML frontmatter**：确保格式正确
```bash
head -20 ~/.openclaw/workspace/skills/my-skill/SKILL.md
```

3. **查看 Agent 日志**：观察 Skill 匹配和执行过程
```bash
openclaw logs --follow
```

### 单元测试建议

为 Skill 添加测试脚本：

```bash
# scripts/test.sh
#!/bin/bash
echo "Testing weather-check skill..."
RESULT=$(curl -s "https://wttr.in/Beijing?format=3" 2>/dev/null)
if [ -n "$RESULT" ]; then
  echo "✅ PASS: Got result: $RESULT"
else
  echo "❌ FAIL: No result"
  exit 1
fi
```

### 调试问题排查流程

| 步骤 | 操作 | 预期结果 |
|------|------|---------|
| 1 | `ls ~/.openclaw/workspace/skills/<name>/SKILL.md` | 文件存在 |
| 2 | `head -5 SKILL.md`，检查 `---` 分隔符 | YAML frontmatter 格式正确 |
| 3 | `python3 -c "import yaml; ..."` 验证 YAML | 无解析错误 |
| 4 | 直接执行脚本命令 | 脚本输出正常 |
| 5 | `openclaw doctor` | Skill 显示已加载 |
| 6 | `openclaw logs --follow` + 发送测试请求 | 日志显示 Skill 被匹配 |

---

## 实操练习

### 练习 1：创建一个 IP 查询 Skill

按照以下步骤创建一个查询公网 IP 的 Skill：

```bash
# 第1步：创建目录
mkdir -p ~/.openclaw/workspace/skills/ip-check
cd ~/.openclaw/workspace/skills/ip-check

# 第2步：编写 SKILL.md（使用 tee 创建文件）
tee SKILL.md << 'EOF'
---
name: ip-check
version: 1.0.0
description: "查询当前服务器的公网 IP 地址"
author: learner
metadata:
  tags: [network, utility]
  triggers:
    - "IP"
    - "公网地址"
---

查询当前服务器的公网 IP 地址和地理位置信息。
使用命令: curl -s https://ipinfo.io/json
示例输出: {"ip": "1.2.3.4", "city": "Wuhan", "country": "CN"}
EOF

# 第3步：创建 _meta.json
cat > _meta.json << 'METAEOF'
{"name":"ip-check","version":"1.0.0","source":"local","installedAt":"2026-03-06T00:00:00Z"}
METAEOF

# 第4步：测试
curl -s https://ipinfo.io/json | python3 -m json.tool

# 第5步：验证
openclaw doctor
```

### 练习 2：批量审计已安装 Skills

编写脚本检查所有已安装 Skill 的健康状态：

```bash
# 运行批量检查
for dir in ~/.openclaw/workspace/skills/*/; do
  name=$(basename "$dir")
  has_skill=$([ -f "$dir/SKILL.md" ] && echo "✅" || echo "❌")
  has_meta=$([ -f "$dir/_meta.json" ] && echo "✅" || echo "❌")
  echo "$name  SKILL.md=$has_skill  _meta.json=$has_meta"
done
```

### 练习 3：为已有 Skill 编写测试

选择一个已安装的 Skill，为其创建 `scripts/test.sh` 测试脚本：

```bash
# 示例：为 ddg-web-search 编写测试
cd ~/.openclaw/workspace/skills/ddg-web-search
mkdir -p scripts

cat > scripts/test.sh << 'EOF'
#!/bin/bash
echo "=== Testing ddg-web-search ==="

# 测试1：检查 SKILL.md 存在
[ -f "../SKILL.md" ] && echo "✅ SKILL.md 存在" || echo "❌ SKILL.md 缺失"

# 测试2：检查 frontmatter 格式
python3 -c "
import yaml
with open('../SKILL.md') as f:
    parts = f.read().split('---')
    meta = yaml.safe_load(parts[1])
    assert 'name' in meta, 'Missing name'
    print('✅ Frontmatter 有效:', meta['name'])
" || echo "❌ Frontmatter 格式错误"

# 测试3：检查依赖命令
command -v curl >/dev/null && echo "✅ curl 可用" || echo "❌ curl 未安装"

echo "=== 测试完成 ==="
EOF

chmod +x scripts/test.sh
bash scripts/test.sh
```

---

## 常见问题 (FAQ)

**Q1: SKILL.md 格式不对怎么办？**

A: 运行 `openclaw doctor` 可自动检测格式问题。最常见的错误是 YAML frontmatter 没有用 `---` 正确包裹，或者字段类型不对（如 `tags` 应该是列表而非字符串）。可以用以下命令快速验证：

```bash
python3 -c "import yaml; print(yaml.safe_load(open('SKILL.md').read().split('---')[1]))"
```

**Q2: Skill 没有被 Agent 识别怎么排查？**

A: 按以下顺序检查：
1. 确认目录在 `~/.openclaw/workspace/skills/` 下
2. 确认 `SKILL.md` 文件名大小写正确
3. 检查 `openclaw.json` 中是否被 `enabled: false` 禁用
4. 运行 `openclaw gateway reload` 重新加载
5. 查看 `openclaw logs --follow` 观察加载过程

**Q3: 如何将 Skill 发布到 ClawdHub？**

A: 参见下一章《Skills 安装与管理实践》，使用 `npx skills add` 命令发布。发布前需确保 SKILL.md 包含完整的 frontmatter 字段和使用示例。

**Q4: 脚本执行权限不足怎么办？**

A: 为脚本添加可执行权限：

```bash
chmod +x ~/.openclaw/workspace/skills/<name>/scripts/*.sh
# 验证
ls -la ~/.openclaw/workspace/skills/<name>/scripts/
```

**Q5: 多个 Skill 的触发词冲突了怎么办？**

A: Agent 会按照匹配度和优先级选择最合适的 Skill。如果冲突严重，建议：
1. 使用更具体的触发词（如"DDG搜索"而非"搜索"）
2. 在 `openclaw.json` 中禁用不需要的 Skill
3. 在请求中明确指定 Skill 名称

---

## 外部参考链接

- [OpenClaw GitHub 仓库](https://github.com/nicepkg/openclaw) — 源码与文档
- [YAML 语法规范](https://yaml.org/spec/1.2.2/) — SKILL.md frontmatter 所用格式
- [语义化版本 (SemVer)](https://semver.org/lang/zh-CN/) — 版本号命名规范
- [ClawdHub 技能市场](https://clawdhub.com) — 发现和分享 Skills
- [MCP 协议规范](https://modelcontextprotocol.io/) — 理解 MCP 集成型 Skill

---


## 最新动态与补充

> 📅 更新时间: 2026-03-09

### 补充 1

OpenClaw is an open-source framework for developing AI agents, and its skills are modular Markdown files that automate tasks for these agents. To install a skill, use `npx clawhub install <skill-slug>`. Skills enhance agent functionality and workflow efficiency.

### 补充 2

- **OpenClaw Application Development - Custom Skills and Plugin ...** (relevance: 77%)
  https://www.tencentcloud.com/techpedia/140775
  OpenClaw Application Development - Custom Skills and Plugin Development Guide - Tencent Cloud. OpenClaw Application Development: Custom Skills and Plugin Developme

### 补充 3

- **Plugins - OpenClaw Docs** (relevance: 72%)
  https://docs.openclaw.ai/tools/plugin
  # Plugins. # ​ Plugins (Extensions). ## ​ Quick start (new to plugins?). `openclaw plugins install @openclaw/voice-call`. ## ​ Available plugins (official). ## ​ Plugin SDK import paths. `openclaw/plugin-sdk/cop

### 补充 4

- **Skills - OpenClaw Docs** (relevance: 64%)
  https://docs.openclaw.ai/tools/skills
  ##### Skills. # Skills. # ​ Skills (OpenClaw). ## ​ Locations and precedence. ## ​ Per-agent vs shared skills. ## ​ Plugins + skills. ## ​ ClawHub (install + sync). ## ​ Security notes. ## ​ Format (AgentSkills +

### 补充 5

- **What are OpenClaw Skills? A 2026 Developer's Guide | DigitalOcean** (relevance: 62%)
  https://www.digitalocean.com/resources/articles/what-are-openclaw-skills
  # What are OpenClaw Skills? OpenClaw skills are designed to make working with OpenClaw’s AI agents more practical, modular, and powerf


## 最新动态与补充

> 📅 更新时间: 2026-03-09

### 补充 1

- **Plugins - OpenClaw Docs** (relevance: 72%)
  https://docs.openclaw.ai/tools/plugin
  # Plugins. # ​ Plugins (Extensions). ## ​ Quick start (new to plugins?). `openclaw plugins install @openclaw/voice-call`. ## ​ Available plugins (official). ## ​ Plugin SDK import paths. `openclaw/plugin-sdk/cop

### 补充 2

- **Skills - OpenClaw Docs** (relevance: 64%)
  https://docs.openclaw.ai/tools/skills
  ##### Skills. # Skills. # ​ Skills (OpenClaw). ## ​ Locations and precedence. ## ​ Per-agent vs shared skills. ## ​ Plugins + skills. ## ​ ClawHub (install + sync). ## ​ Security notes. ## ​ Format (AgentSkills +

### 补充 3

- **What are OpenClaw Skills? A 2026 Developer's Guide | DigitalOcean** (relevance: 62%)
  https://www.digitalocean.com/resources/articles/what-are-openclaw-skills
  # What are OpenClaw Skills? OpenClaw skills are designed to make working with OpenClaw’s AI agents more practical, modular, and powerf

### 补充 4

OpenClaw skills are Markdown files defining agent behaviors. To publish, use `clawhub publish`. Follow OpenClaw's CLI for missing requirements.

### 补充 5

- **Building Custom OpenClaw Skills: A Hands-On Tutorial - DataCamp** (relevance: 100%)
  https://www.datacamp.com/es/tutorial/building-open-claw-skills
  Learn how to build OpenClaw skills from scratch, connect external APIs, configure Docker sandboxing, and publish to ClawHub in this step-by-step

## 本章小结

本章系统讲解了 OpenClaw Skills 插件体系的核心知识：

- **体系架构**：理解了 Skill 从意图匹配到执行返回的完整工作流
- **目录结构**：掌握了 SKILL.md、_meta.json 等关键文件的规范
- **编写规范**：学会了 YAML frontmatter 和正文的编写标准与质量检查方法
- **开发实战**：通过天气查询 Skill 实例走通了完整开发流程
- **批量管理**：掌握了列出、更新、禁用/启用等批量操作
- **调试测试**：了解了 Skill 开发中的排错与测试策略

遇到问题时，善用 `openclaw doctor` 进行诊断，配合 `openclaw logs --follow` 追踪 Agent 加载与匹配 Skill 的过程。

---
[⬅️ 上一章：部署与环境初始化](02-部署与环境初始化.md) | [📑 目录](README.md) | [➡️ 下一章：Skills 安装与管理实践](04-Skills%20安装与管理实践.md)
---
