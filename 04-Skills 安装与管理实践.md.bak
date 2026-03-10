---
[⬅️ 上一章：Skills 插件体系与批量开发](03-Skills%20插件体系与批量开发.md) | [📑 目录](README.md) | [➡️ 下一章：ClawHub 平台与技能分发](05-ClawHub%20平台与技能分发.md)
---

# 第4章：Skills 安装与管理实践

> **难度**: ⭐⭐ 中级 | **预计阅读**: 15 分钟 | **前置章节**: [第 3 章](03-Skills%20插件体系与批量开发.md)

> 本章介绍如何安装、管理和维护 OpenClaw Skills，包括从 ClawdHub 安装、手动安装、版本管理和安全审查。掌握 Skills 管理是提升 Agent 能力的关键一步。

---

## 📑 目录

- [4.1 Skills 安装方式](#41-skills-安装方式)
- [4.2 Skills 发现与搜索](#42-skills-发现与搜索)
- [4.3 版本管理](#43-版本管理)
- [4.4 安全审查](#44-安全审查)
- [4.5 Skill 配置与 openclaw.json](#45-skill-配置与-openclawjson)
- [4.6 实战：搭建搜索技能组合](#46-实战搭建搜索技能组合)
- [实操练习](#实操练习)
- [常见问题 (FAQ)](#常见问题-faq)
- [参考资料](#参考资料)
- [本章小结](#本章小结)

---

## 4.1 Skills 安装方式

OpenClaw 提供多种 Skill 安装方式，适应不同场景需求。下表汇总了各安装方式的特性对比：

| 安装方式 | 适用场景 | 是否需要网络 | 自动更新 | 难度 |
|---------|---------|------------|---------|------|
| ClawdHub 安装 | 官方审核技能 | 是 | 支持 | ⭐ |
| npx skills CLI | 快速搜索与安装 | 是 | 支持 | ⭐ |
| 手动 Git Clone | 自定义或私有技能 | 首次需要 | 手动 | ⭐⭐ |
| MCP 工具集成 | 外部工具与 API 服务 | 是 | 取决于服务端 | ⭐⭐ |

### 方式一：ClawdHub 安装（推荐）

ClawdHub 是 OpenClaw 的官方技能市场，提供经过审核的 Skills：

```bash
clawdhub install tavily-search
clawdhub install memory
clawdhub install proactive-agent
```

安装完成后，Skill 会自动放置到 `~/.openclaw/workspace/skills/` 目录下，并注册到系统配置中。你可以立即在 Agent 对话中使用新安装的能力。

### 方式二：npx skills CLI

```bash
# 搜索技能
npx skills find "web search"

# 安装技能
npx skills add tavily-search

# 检查更新
npx skills check

# 批量更新
npx skills update
```

### 方式三：手动安装

从 GitHub 或其他来源手动安装：

```bash
git clone https://github.com/author/my-skill.git \
  ~/.openclaw/workspace/skills/my-skill
```

> [!NOTE]
> 手动安装的 Skill 需要确保目录中包含 `SKILL.md` 文件，Agent 才能正确识别并加载。

### 方式四：MCP 工具集成

通过 McPorter 添加 MCP 服务器（可提供工具级 Skill）：

```bash
mcporter config add exa https://mcp.exa.ai/mcp
mcporter config add xiaohongshu http://localhost:18060/mcp
```

MCP 方式适合集成已有的 REST API 或第三方 AI 工具服务，无需编写完整的 Skill 目录结构。

---

## 4.2 Skills 发现与搜索

找到适合需求的 Skills 是高效使用 OpenClaw 的前提。

### ClawdHub 浏览

访问 [https://skills.sh](https://skills.sh/) 在线浏览所有可用技能。页面支持按分类、热度、最近更新等维度筛选，同时展示安装量和用户评分。

### 命令行搜索

```bash
# 搜索包含关键词的技能
npx skills find "search"
npx skills find "automation"
npx skills find "feishu"
```

### 本地已安装列表

```bash
ls ~/.openclaw/workspace/skills/
# 详细信息：遍历所有已安装 Skill 并展示描述
for dir in ~/.openclaw/workspace/skills/*/; do
  name=$(basename "$dir")
  if [ -f "$dir/SKILL.md" ]; then
    desc=$(grep -oP 'description:\s*"\K[^"]+' "$dir/SKILL.md" | head -1)
    echo "  📦 $name: $desc"
  fi
done
```

---

## 4.3 版本管理

Skills 支持语义化版本管理（SemVer），便于追踪变更和控制兼容性。

### 版本号含义

| 版本段 | 名称 | 含义 | 示例 |
|-------|------|------|------|
| Major | 主版本号 | 不兼容的 API 变更 | v1.0.0 → v2.0.0 |
| Minor | 次版本号 | 新增功能，向后兼容 | v1.0.0 → v1.1.0 |
| Patch | 修订号 | Bug 修复 | v1.0.0 → v1.0.1 |

### 查看当前版本

```bash
# 查看单个 Skill 版本
head -10 ~/.openclaw/workspace/skills/tavily-search/SKILL.md

# 查看所有 Skill 版本
npx skills check
```

### 更新策略

```bash
# 检查可用更新
npx skills check

# 更新所有
npx skills update

# 更新指定 Skill
npx skills update tavily-search
```

### 版本回退

手动安装的 Skills 支持 Git 回退：

```bash
cd ~/.openclaw/workspace/skills/my-skill
git log --oneline
git checkout v1.0.0  # 回退到指定版本
```

---

## 4.4 安全审查

安装第三方 Skills 前应进行安全审查。OpenClaw 内置了 `skill-vetter` 技能，专门用于安全检查。

### skill-vetter 审查流程

| 审查阶段 | 检查内容 | 重要等级 |
|---------|---------|---------|
| 来源检查 | 验证 Skill 来源是否可信 | ⚠️ 高 |
| 代码审查 (MANDATORY) | 检查脚本中的危险操作 | 🔴 必须 |
| 权限范围 | 评估 Skill 访问的系统资源 | ⚠️ 高 |
| 红旗检测 | 扫描可疑模式（`rm -rf`、`eval`、网络外泄等） | 🔴 必须 |

### 使用方法

在安装前，让 Agent 对 Skill 进行审查：

```text
请帮我审查这个 Skill: https://github.com/author/suspect-skill
```

### 安全配置

OpenClaw 提供执行审批机制，配置文件位于 `~/.openclaw/exec-approvals.json`：

```json
{
  "autoApprove": ["ls", "cat", "echo"],
  "requireApproval": ["rm", "curl", "wget"],
  "deny": ["rm -rf /"]
}
```

### 最佳实践

- 优先使用 ClawdHub 官方审核的 Skills
- 安装前阅读 SKILL.md 了解权限范围
- 对包含 `scripts/` 的 Skills 逐一检查脚本内容
- 定期运行 `npx skills check` 检查安全更新
- 在生产环境中严格限制 `autoApprove` 列表

---

## 4.5 Skill 配置与 openclaw.json

部分 Skills 需要在主配置文件 `~/.openclaw/openclaw.json` 中进行额外配置。

### 技能启用/禁用

```json
{
  "skills": {
    "entries": {
      "tavily": {
        "enabled": true,
        "apiKey": "tvly-xxx"
      },
      "ddg-search": {
        "enabled": true
      },
      "notion": {
        "enabled": false
      }
    }
  }
}
```

### 需要 API Key 的 Skills

| Skill | 环境变量 | 获取方式 | 是否必需 | 费用 |
|-------|---------|---------|---------|------|
| tavily-search | `TAVILY_API_KEY` | https://tavily.com | 是 | 免费层可用 |
| notion | `NOTION_KEY` | https://developers.notion.com | 是 | 免费 |
| gog | Google OAuth | `gog auth` | 是 | 免费 |
| ddg-search | 无 | 免费，无需 Key | 否 | 免费 |

### MCP 服务器配置

通过 McPorter 管理的 MCP 型 Skill：

```bash
# 查看已配置的 MCP 服务器
mcporter list

# 添加新服务器
mcporter config add <name> <url>

# 调用 MCP 工具
mcporter call 'exa.web_search_exa(query: "AI agents")'
```

---

## 4.6 实战：搭建搜索技能组合

以搭建完整的搜索能力为例，展示 Skills 安装管理实战。

### 目标

构建多引擎搜索能力：Tavily（主力）→ DuckDuckGo（免费备选）→ Exa（MCP）

### Step 1：安装搜索 Skills

```bash
# 安装 Tavily（需要 API Key）
clawdhub install tavily-search
# 配置 API Key — 编辑 ~/.openclaw/openclaw.json → skills.entries.tavily.apiKey

# 安装 DuckDuckGo（零依赖）
clawdhub install ddg-web-search

# 安装 Exa MCP
mcporter config add exa https://mcp.exa.ai/mcp
```

### Step 2：验证安装

```bash
# 测试 Tavily
node ~/.openclaw/workspace/skills/tavily-search/scripts/search.mjs "test"

# 测试 DuckDuckGo
curl -sL "https://lite.duckduckgo.com/lite/?q=test&kl=au-en"

# 测试 Exa
mcporter call 'exa.web_search_exa(query: "test", numResults: 3)'
```

### Step 3：配置优先级

Agent 会根据 SKILL.md 的 triggers 和上下文自动选择合适的搜索引擎。可在对话中指定：

```text
搜索 "OpenClaw 教程"              ← Agent 自动选择
用 Tavily 搜索 "OpenClaw 教程"    ← 指定引擎
```

---

## 实操练习

通过以下练习动手掌握 Skills 的完整生命周期管理。

### 练习1：安装并测试一个免费搜索 Skill

1. 使用 ClawdHub 安装 `ddg-web-search`：
   ```bash
   clawdhub install ddg-web-search
   ```
2. 确认 Skill 已成功安装，查看其描述文件：
   ```bash
   ls ~/.openclaw/workspace/skills/ddg-web-search/
   cat ~/.openclaw/workspace/skills/ddg-web-search/SKILL.md
   ```
3. 在 Agent 对话中测试搜索功能：
   ```text
   用 DuckDuckGo 搜索 "OpenClaw 最新版本"
   ```
4. 验证搜索结果正常返回，记录返回条数和内容质量。

### 练习2：对第三方 Skill 进行安全审查

1. 在 GitHub 上找一个第三方 Skill 仓库（可使用 `npx skills find` 搜索）。
2. 请求 Agent 进行安全审查：
   ```text
   请帮我审查这个 Skill: https://github.com/example/example-skill
   ```
3. 仔细阅读审查报告，重点关注：
   - 是否包含危险命令（`rm -rf`、`eval`、`exec`）
   - 网络请求的目标地址是否合理
   - 文件读写范围是否受限于工作目录
4. 根据审查结果决定是否安装，记录审查判断依据。

### 练习3：搭建多引擎搜索并对比效果

1. 按照 4.6 节完整步骤安装 Tavily 和 DuckDuckGo 两个搜索引擎。
2. 分别用两个引擎搜索相同关键词并记录结果：
   ```text
   用 Tavily 搜索 "AI agent framework 2026"
   用 DuckDuckGo 搜索 "AI agent framework 2026"
   ```
3. 从以下维度对比结果：

   | 维度 | Tavily | DuckDuckGo |
   |------|--------|------------|
   | 返回条数 | | |
   | 结果质量 | | |
   | 响应速度 | | |
   | 是否需要 API Key | 是 | 否 |

4. 在 `openclaw.json` 中调整搜索引擎优先配置，验证切换效果。

---

## 常见问题 (FAQ)

**Q1: 安装 Skill 后提示找不到，Agent 无法使用怎么办？**

A: 按以下顺序排查：
1. 确认 Skill 目录下存在 `SKILL.md` 文件：`ls ~/.openclaw/workspace/skills/<name>/SKILL.md`
2. 重启 Agent 或新开一个会话（已加载的 Session 不会自动发现新 Skill）
3. 检查 `openclaw.json` 中是否有 `"enabled": false` 的配置覆盖

**Q2: API Key 应该放在环境变量还是 openclaw.json 中？**

A: 两种方式都支持，环境变量优先级更高。推荐做法：
- **开发环境**：写入 `openclaw.json` 的 `skills.entries` 方便调试
- **生产环境**：使用环境变量，避免密钥写入配置文件
```bash
export TAVILY_API_KEY="tvly-your-key-here"
```

**Q3: 如何完全卸载一个 Skill？**

A: 分两步操作：
```bash
# 1. 删除 Skill 目录
rm -rf ~/.openclaw/workspace/skills/<skill-name>

# 2.（可选）从 openclaw.json 中移除对应配置项
# 编辑 ~/.openclaw/openclaw.json，删除 skills.entries 中的对应条目
```

**Q4: MCP 服务器连接超时怎么排查？**

A: 按以下步骤逐一排查：
```bash
# 1. 检查 URL 是否可达
curl -I <mcp-url>

# 2. 查看 McPorter 状态
mcporter list

# 3. 检查防火墙与网络
ping <mcp-host>
```
如果是 localhost 服务，确认对应进程正在运行。

**Q5: 多个 Skills 提供相同功能会冲突吗？**

A: 不会冲突。OpenClaw 的 Skill 系统基于目录隔离，各 Skill 独立运行。当多个 Skill 提供相似能力时，Agent 会根据对话上下文和 `SKILL.md` 中的 triggers 自动选择最合适的一个。你也可以在对话中明确指定使用哪个 Skill。

---

## 参考资料

- [ClawdHub 官方技能市场](https://skills.sh/) — 浏览和安装官方审核的 Skills
- [OpenClaw Skills 开发文档](https://docs.openclaw.com/skills/) — Skill 结构规范与开发指南
- [McPorter MCP 集成指南](https://docs.openclaw.com/mcp/) — MCP 服务器配置与工具调用
- [语义化版本管理规范 (SemVer)](https://semver.org/lang/zh-CN/) — 版本号命名规范参考
- [OpenClaw GitHub 仓库](https://github.com/openclaw/openclaw) — 源码与 Issue 追踪

---


## 最新动态与补充

> 📅 更新时间: 2026-03-09

### 补充 1

To install OpenClaw skills, use ClawHub or the macOS app, which installs them on the gateway host. Essential skills include workflow automation and web search tools.

### 补充 2

- **OpenClaw Setup Guide: 25 Tools + 53 Skills Explained | WenHao Yu** (relevance: 100%)
  https://yu-wenhao.com/en/blog/openclaw-tools-skills-tutorial/
  ![Image 3: OpenClaw concentric circle architecture: Layer 1 core tools (read, write, exec), Layer 2 advanced tools (browser, memory, automation),

### 补充 3

- **Skills - OpenClaw Docs** (relevance: 100%)
  https://docs.openclaw.ai/platforms/mac/skills
  OpenClaw home pagelight logodark logo. ##### Platforms overview. ##### macOS companion app. # Skills (macOS). # Skills. The macOS app surfaces OpenClaw skills via the gateway; it does not parse skills lo

### 补充 4

- **How to Install and Use OpenClaw Skills (Full Beginner Guide)** (relevance: 100%)
  https://www.youtube.com/watch?v=hXEKgSnD1Gs
  Learn how to unlock the full power of OpenClaw by installing and using Skills — the modules that turn your AI agent from “basic” into

### 补充 5

- **Setting Up Skills In Openclaw - Nwosu Rosemary - Medium** (relevance: 100%)
  https://nwosunneoma.medium.com/setting-up-skills-in-openclaw-d043b76303be
  When creating your SKILL.md, ensure that it follows what Openclaw expects — name, description, and metadata. Then I modified AGENTS.md and SOU


## 最新动态与补充

> 📅 更新时间: 2026-03-09

### 补充 1

- **OpenClaw Setup Guide: 25 Tools + 53 Skills Explained | WenHao Yu** (relevance: 100%)
  https://yu-wenhao.com/en/blog/openclaw-tools-skills-tutorial/
  ![Image 3: OpenClaw concentric circle architecture: Layer 1 core tools (read, write, exec), Layer 2 advanced tools (browser, memory, automation),

### 补充 2

- **Skills - OpenClaw Docs** (relevance: 100%)
  https://docs.openclaw.ai/platforms/mac/skills
  OpenClaw home pagelight logodark logo. ##### Platforms overview. ##### macOS companion app. # Skills (macOS). # Skills. The macOS app surfaces OpenClaw skills via the gateway; it does not parse skills lo

### 补充 3

- **7 Essential OpenClaw Skills You Need Right Now - KDnuggets** (relevance: 100%)
  https://www.kdnuggets.com/7-essential-openclaw-skills-you-need-right-now
  # 7 Essential OpenClaw Skills You Need Right Now. Skills are what make OpenClaw more than a local assistant, and these are the most popular

### 补充 4

ClawHub is a marketplace for OpenClaw AI agents to publish and share skill bundles. It uses semantic search and is partnered with VirusTotal for security scanning. It helps developers distribute and discover new agent skills.

### 补充 5

- **ClawHub - AI Agent Store** (relevance: 85%)
  https://aiagentstore.ai/ai-agent/clawhub
  # ClawHub. ## Overview. Skill registry for OpenClaw agents: publish, version, and install AgentSkills bundles with semantic (vector) search and CLI tooling. ### Best For Professions:. ClawHub is a skill regi


## 最新动态与补充

> 📅 更新时间: 2026-03-10

### 补充 1

OpenClaw skills are modular components that enhance AI agent functionality; they are installed via `npx clawhub install <skill-slug>`. Skills are managed remotely on the gateway host, not locally on macOS.

### 补充 2

- **Skills - OpenClaw Docs** (relevance: 80%)
  https://docs.openclaw.ai/platforms/mac/skills
  OpenClaw home pagelight logodark logo. ##### Platforms overview. ##### macOS companion app. # Skills (macOS). # Skills. The macOS app surfaces OpenClaw skills via the gateway; it does not parse skills loc

### 补充 3

- **Best Openclaw Skills You Should Install (From ClawHub's 500+ Skills)** (relevance: 76%)
  https://www.reddit.com/r/AI_Agents/comments/1r2u356/best_openclaw_skills_you_should_install_from/
  [Skip to main content](https://www.reddit.com/r/AI_Agents/comments/1r2u356/best_openclaw_skills_you_should

### 补充 4

- **What are OpenClaw Skills? A 2026 Developer's Guide | DigitalOcean** (relevance: 75%)
  https://www.digitalocean.com/resources/articles/what-are-openclaw-skills
  # What are OpenClaw Skills? OpenClaw skills are designed to make working with OpenClaw’s AI agents more practical, modular, and powerf

### 补充 5

ClawHub is a marketplace for OpenClaw agents, allowing developers to publish and version AgentSkills bundles. It uses semantic search and scanning by VirusTotal to enhance security. Beware of malicious skills disguised as legitimate tools.

## 本章小结

- **Skills 安装方式**：掌握 ClawdHub、npx CLI、手动克隆、MCP 集成四种安装方式，按需选择
- **Skills 发现与搜索**：通过 ClawdHub 网站和命令行快速定位所需技能
- **版本管理**：使用语义化版本管理，支持检查更新、批量更新与版本回退
- **安全审查**：安装前通过 skill-vetter 进行代码审查和红旗检测，保障系统安全
- **配置管理**：在 openclaw.json 中管理 Skill 的启用状态、API Key 和 MCP 服务器
- **实战组合**：通过多引擎搜索组合展示 Skill 协同工作的最佳实践
- 遇到问题时，善用 `openclaw doctor` 进行诊断。

---
[⬅️ 上一章：Skills 插件体系与批量开发](03-Skills%20插件体系与批量开发.md) | [📑 目录](README.md) | [➡️ 下一章：ClawHub 平台与技能分发](05-ClawHub%20平台与技能分发.md)
---
