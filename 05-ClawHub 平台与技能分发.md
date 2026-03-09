---
[⬅️ 上一章：Skills 安装与管理实践](04-Skills%20安装与管理实践.md) | [📑 目录](README.md) | [➡️ 下一章：自动化命令与脚本集成](06-自动化命令与脚本集成.md)
---

# 第5章：ClawHub 平台与技能分发

> **难度**: ⭐⭐ 中级 | **预计阅读**: 18 分钟 | **前置章节**: [第 3-4 章](03-Skills%20插件体系与批量开发.md)

> 本章介绍 ClawHub（又名 skills.sh）技能市场平台，包括如何浏览、安装、发布技能，以及社区协作流程。通过本章学习，你将掌握从技能发现到发布上架的完整工作流，并能独立参与社区技能生态建设。

---

## 📖 目录

- [5.1 ClawHub 平台简介](#51-clawhub-平台简介)
- [5.2 浏览与搜索技能](#52-浏览与搜索技能)
- [5.3 安装与管理技能](#53-安装与管理技能)
- [5.4 发布技能到 ClawHub](#54-发布技能到-clawhub)
- [5.5 社区协作](#55-社区协作)
- [5.6 实操练习](#56-实操练习)
- [5.7 常见问题 (FAQ)](#57-常见问题-faq)
- [5.8 参考资源](#58-参考资源)
- [本章小结](#本章小结)

---

## 5.1 ClawHub 平台简介

ClawHub（访问地址 [https://skills.sh](https://skills.sh)）是 OpenClaw 的官方技能市场，为 AI Agent 提供经过审核的 Skills 插件。它既是技能的分发中心，也是社区协作的枢纽。开发者可以在此发布自己开发的 Skills，用户则可以一键搜索、安装和评价这些技能。

### 核心功能

ClawHub 提供以下核心能力：

- **浏览与搜索**：按分类、关键词、评分等多维度发现 Skills
- **一键安装**：通过命令行将 Skills 安装到本地 OpenClaw 实例
- **技能评分与评论**：用户可为已使用的技能打分并留下使用心得
- **开发者发布与版本管理**：支持语义化版本控制，自动记录更新历史
- **社区贡献与协作**：支持 Fork、Issue、Pull Request 等协作方式
- **安全审查**：所有公开发布的技能都经过自动化安全扫描

### 平台架构概览

ClawHub 的技术架构分为前端展示、API 服务和后端审核三层：

| 层级 | 组件 | 说明 |
|------|------|------|
| 前端 | skills.sh 网站 | 技能浏览、搜索、详情页面 |
| API | Skills CLI | 命令行工具，支持 install/find/publish 等操作 |
| 后端 | 审核引擎 | skill-vetter 自动安全扫描 + 人工复审 |
| 存储 | 技能仓库 | 版本化存储所有已发布技能的元数据与代码 |

### 快速体验

```bash
# 验证 skills CLI 是否可用
npx skills --version

# 从 ClawHub 安装一个技能
npx skills install tavily-search

# 搜索可用技能
npx skills find "关键词"
```

安装完成后，可通过以下命令确认技能已就绪：

```bash
# 列出所有已安装的技能
openclaw skills list
```

---

## 5.2 浏览与搜索技能

ClawHub 提供网页和命令行两种方式来发现技能。根据使用场景，你可以选择最适合的方式。

### 在线浏览

访问 [https://skills.sh](https://skills.sh)，页面提供按分类、热度、最新发布等维度的浏览功能。每个技能卡片显示名称、简介、版本号、安装量和评分。

### 命令行搜索

命令行搜索更适合开发者和自动化场景。`npx skills find` 支持多种搜索参数：

```bash
# 按关键词搜索
npx skills find "search"
npx skills find "automation"

# 查看技能详情（包括版本、依赖、作者等信息）
npx skills info tavily-search
```

### 搜索参数说明

| 参数 | 用途 | 示例 |
|------|------|------|
| 关键词 | 按名称/描述模糊匹配 | `npx skills find "web search"` |
| `--category` | 按分类筛选 | `npx skills find --category security` |
| `--sort` | 排序方式（stars/downloads/updated） | `npx skills find "search" --sort stars` |
| `--limit` | 限制返回结果数量 | `npx skills find "search" --limit 5` |

### 常见分类

| 分类 | 说明 | 推荐技能 | 典型用途 |
|------|------|---------|---------|
| 搜索 | 网络搜索引擎集成 | tavily-search, ddg-web-search | 让 Agent 能联网搜索信息 |
| 办公 | 办公软件集成 | gog, notion | 自动化文档和项目管理 |
| 开发 | 开发工具 | github, file-search | 代码仓库操作与文件检索 |
| AI | Agent 增强 | proactive-agent, memory | 增强 Agent 自主性与记忆力 |
| 安全 | 安全审查 | skill-vetter | Skill 安全评估与扫描 |
| 通讯 | 消息集成 | feishu, slack | 消息推送与通知 |

### 查看技能详情输出示例

执行 `npx skills info tavily-search` 后，输出类似如下 JSON 结构：

```json
{
  "name": "tavily-search",
  "version": "1.2.0",
  "description": "Tavily AI Search Engine integration for OpenClaw",
  "author": "openclaw-community",
  "category": "search",
  "downloads": 1520,
  "rating": 4.7,
  "dependencies": {
    "tavily-api-key": "required"
  },
  "homepage": "https://skills.sh/tavily-search"
}
```

---

## 5.3 安装与管理技能

### 安装技能

从 ClawHub 安装技能只需一条命令：

```bash
# 安装最新版本
npx skills install tavily-search

# 安装指定版本
npx skills install tavily-search@1.2.0
```

安装完成后，技能文件会存放在本地 `~/.openclaw/workspace/skills/` 目录下。

### 查看已安装技能

```bash
# 列出所有已安装的技能及其版本
openclaw skills list
```

### 更新与卸载

```bash
# 更新单个技能到最新版
npx skills update tavily-search

# 卸载技能
npx skills uninstall tavily-search
```

### 安装前后对比

| 对比项 | 安装前 | 安装后 |
|--------|--------|--------|
| skills 目录 | 无 tavily-search 文件夹 | 新增 `tavily-search/` 目录 |
| Agent 能力 | 无法执行网络搜索 | 可通过 `tavily_search` 工具搜索 |
| SKILL.md | 不存在 | 包含技能元数据和配置 |
| 配置需求 | 无 | 需要设置 `TAVILY_API_KEY` 环境变量 |

### 技能配置示例

部分技能安装后需要额外配置。以 `tavily-search` 为例，需要在环境变量或配置文件中设置 API Key：

```yaml
# ~/.openclaw/workspace/skills/tavily-search/config.yaml 示例
name: tavily-search
version: 1.2.0
settings:
  api_key: "${TAVILY_API_KEY}"
  search_depth: "advanced"
  max_results: 5
  include_domains: []
  exclude_domains: []
```

也可以通过环境变量设置：

```bash
# 设置环境变量
export TAVILY_API_KEY="tvly-xxxxxxxxxxxxxxxx"

# 验证技能是否正常工作
openclaw skills test tavily-search
```

---

## 5.4 发布技能到 ClawHub

开发完成的 Skill 可以发布到 ClawHub 供社区使用。发布流程分为准备、验证、提交三个阶段。

### 发布前检查清单

在发布之前，请确认以下事项：

| 检查项 | 要求 | 验证命令 |
|--------|------|---------|
| SKILL.md | frontmatter 包含 name/version/description | `npx skills validate` |
| README.md | 包含使用说明和示例 | 人工检查 |
| 脚本可运行 | 所有脚本可独立执行 | `openclaw skills test <name>` |
| 依赖声明 | 在 SKILL.md 中声明所有依赖 | `npx skills validate` |
| 安全审查 | 通过 skill-vetter 扫描 | `npx skills vet .` |

### SKILL.md 模板

发布技能时，`SKILL.md` 是最关键的文件。以下是标准模板：

```yaml
---
name: my-awesome-skill
version: 1.0.0
description: "一个示例技能，用于演示发布流程"
author: "your-github-username"
category: "tools"
tags:
  - example
  - tutorial
dependencies:
  - node: ">=18.0.0"
permissions:
  - network
  - filesystem
---
```

```markdown
# My Awesome Skill

## 功能说明
这个技能提供 XXX 功能……

## 使用方法
安装后，Agent 可通过以下方式调用：
- 工具名：`my_awesome_tool`
- 参数：`query` (string)

## 配置
需要设置环境变量 `MY_API_KEY`。
```

### Step-by-Step 发布流程

**Step 1：初始化发布配置**

```bash
# 进入技能目录
cd ~/.openclaw/workspace/skills/my-awesome-skill

# 初始化发布配置（生成 .skillrc 文件）
npx skills init
```

初始化后会生成 `.skillrc` 配置文件：

```json
{
  "name": "my-awesome-skill",
  "registry": "https://skills.sh",
  "publishConfig": {
    "access": "public"
  }
}
```

**Step 2：验证技能格式与安全性**

```bash
# 验证 SKILL.md 格式是否正确
npx skills validate

# 运行安全审查
npx skills vet .

# 运行技能测试
openclaw skills test my-awesome-skill
```

验证通过后，会显示类似输出：

```
✅ SKILL.md format: valid
✅ README.md: found
✅ Dependencies: declared
✅ Security scan: passed
Ready to publish!
```

**Step 3：发布到 ClawHub**

```bash
# 发布（首次发布需要 GitHub 登录授权）
npx skills publish
```

发布成功后，你的技能就可以在 [https://skills.sh](https://skills.sh) 上被搜索和安装了。

### 版本更新

当需要发布新版本时：

```bash
# 1. 修改 SKILL.md 中的 version 字段
# 2. 更新 CHANGELOG（推荐）
# 3. 重新验证并发布
npx skills validate
npx skills publish
```

版本号建议遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范：

| 版本变更 | 规则 | 示例 |
|---------|------|------|
| 修复 Bug | patch +1 | 1.0.0 → 1.0.1 |
| 新增功能（向后兼容） | minor +1 | 1.0.0 → 1.1.0 |
| 破坏性变更 | major +1 | 1.0.0 → 2.0.0 |

---

## 5.5 社区协作

ClawHub 鼓励社区贡献与协作。无论你是用户还是开发者，都可以通过多种方式参与技能生态建设。

### 贡献方式

- **报告问题**：在 Skill 的 GitHub 仓库提交 Issue，描述复现步骤与期望行为
- **提交改进**：Fork → 修改 → Pull Request，遵循项目的贡献指南
- **分享经验**：编写使用教程和最佳实践，帮助其他用户上手
- **评分评论**：在 ClawHub 对使用过的 Skill 评分，为社区提供参考

### 开发协作流程

```bash
# Step 1: Fork 并克隆他人的 Skill
git clone https://github.com/author/skill-name.git
cd skill-name

# Step 2: 创建功能分支
git checkout -b feature/improve-search

# Step 3: 修改代码并本地测试
openclaw skills test skill-name

# Step 4: 提交修改
git add .
git commit -m "feat: improve search accuracy"

# Step 5: 推送并创建 Pull Request
git push origin feature/improve-search
# 然后在 GitHub 上创建 PR
```

### 社区贡献最佳实践

| 实践 | 说明 |
|------|------|
| 先提 Issue 再写代码 | 确认需求后再动手，避免无效工作 |
| 小步提交 | 每个 PR 只解决一个问题，方便 Review |
| 包含测试 | 新功能或修复都应附带测试验证 |
| 更新文档 | 功能变更时同步更新 README 和 SKILL.md |

---

## 5.6 实操练习

以下练习帮助你掌握 ClawHub 的核心操作。请按步骤依次执行。

### 练习 1：搜索并安装一个技能

**目标**：从 ClawHub 搜索并安装一个搜索类技能。

```bash
# Step 1: 搜索搜索类技能
npx skills find "search"

# Step 2: 查看某个技能的详细信息
npx skills info ddg-web-search

# Step 3: 安装该技能
npx skills install ddg-web-search

# Step 4: 验证安装结果
openclaw skills list | grep ddg-web-search
```

### 练习 2：为已有技能创建发布配置

**目标**：为一个本地开发的技能生成标准的发布文件结构。

```bash
# Step 1: 进入技能目录（假设你已有一个技能）
cd ~/.openclaw/workspace/skills/my-test-skill

# Step 2: 确认 SKILL.md 存在且格式正确
cat SKILL.md

# Step 3: 初始化发布配置
npx skills init

# Step 4: 运行格式验证
npx skills validate

# Step 5: 运行安全扫描
npx skills vet .
```

### 练习 3：模拟社区协作流程

**目标**：体验 Fork → 修改 → 测试的协作流程。

```bash
# Step 1: 克隆一个示例技能仓库
git clone https://github.com/openclaw-community/example-skill.git
cd example-skill

# Step 2: 创建自己的分支
git checkout -b fix/typo-in-readme

# Step 3: 做一个小修改（如修正 README 中的 typo）
sed -i 's/Opnclaw/OpenClaw/g' README.md

# Step 4: 验证修改
git diff

# Step 5: 提交修改
git add README.md
git commit -m "fix: correct typo in README"
```

---

## 5.7 常见问题 (FAQ)

### Q1：如何注册 ClawHub 账号？

**A**：访问 [https://skills.sh](https://skills.sh)，点击右上角"登录"按钮，使用 GitHub 账号进行 OAuth 授权即可。无需额外注册流程。

### Q2：发布的 Skill 审核需要多久？

**A**：自动化安全扫描通常在 5 分钟内完成。如果触发了人工复审，可能需要 1-3 个工作日。你可以通过以下命令查看审核状态：

```bash
npx skills status my-awesome-skill
```

### Q3：Skill 被拒绝发布怎么办？

**A**：拒绝原因通常有以下几类：

| 拒绝原因 | 解决方法 |
|---------|---------|
| SKILL.md 格式不符 | 运行 `npx skills validate` 查看具体错误并修复 |
| 安全问题 | 运行 `npx skills vet .` 查看安全报告，修复风险代码 |
| 缺少 README | 编写包含使用说明和示例的 README.md |
| 依赖未声明 | 在 SKILL.md frontmatter 中补充 dependencies 字段 |

修复后重新执行 `npx skills publish` 即可。

### Q4：如何在发布前本地测试技能？

**A**：使用 OpenClaw 内置的测试命令：

```bash
# 运行技能的内置测试
openclaw skills test my-awesome-skill

# 也可手动触发技能调用（交互模式）
openclaw chat --skill my-awesome-skill
```

### Q5：已发布的技能如何撤销或删除？

**A**：已发布的技能版本无法删除（防止破坏依赖链），但你可以发布一个新版本并在 README 中标注"废弃"（deprecated）。如确需删除，请通过 [skills.sh](https://skills.sh) 联系管理员。

---

## 5.8 参考资源

- **ClawHub 官方网站**：[https://skills.sh](https://skills.sh) — 浏览和搜索所有可用技能
- **OpenClaw Skills 开发文档**：[https://docs.openclaw.io/skills](https://docs.openclaw.io/skills) — Skills 开发与发布完整指南
- **语义化版本规范**：[https://semver.org/lang/zh-CN/](https://semver.org/lang/zh-CN/) — 版本号命名规范参考
- **OpenClaw GitHub 组织**：[https://github.com/openclaw-community](https://github.com/openclaw-community) — 社区开源项目与示例

---


## 最新动态与补充

> 📅 更新时间: 2026-03-09

### 补充 1

OpenClaw skills are modular tools that enhance AI agent functionality; the most popular include web search and GitHub integration; beware of malicious skills found in ClawHub.

### 补充 2

- **Best ClawHub Skills: A Complete Guide - DataCamp** (relevance: 100%)
  https://www.datacamp.com/blog/best-clawhub-skills
  * tavily-web-search is the most widely installed search skill on ClawHub. It connects to the Tavily API, which is optimized for AI agents rather than human browsers. * githu

### 补充 3

- **Best Openclaw Skills You Should Install (From ClawHub's 500+ Skills)** (relevance: 100%)
  https://www.reddit.com/r/AI_Agents/comments/1r2u356/best_openclaw_skills_you_should_install_from/
  [Skip to main content](https://www.reddit.com/r/AI_Agents/comments/1r2u356/best_openclaw_skills_you_shoul

### 补充 4

- **OpenClaw Setup Guide: 25 Tools + 53 Skills Explained | WenHao Yu** (relevance: 100%)
  https://yu-wenhao.com/en/blog/openclaw-tools-skills-tutorial/
  ![Image 3: OpenClaw concentric circle architecture: Layer 1 core tools (read, write, exec), Layer 2 advanced tools (browser, memory, automation),

### 补充 5

- **Hundreds of Malicious Skills Found in OpenClaw's ClawHub** (relevance: 100%)
  https://www.esecurityplanet.com/threats/hundreds-of-malicious-skills-found-in-openclaws-clawhub/
  Link to What is Network Security? Learn about the fundamentals of network security and how to protect your organizatio


## 最新动态与补充

> 📅 更新时间: 2026-03-09

### 补充 1

- **Best ClawHub Skills: A Complete Guide - DataCamp** (relevance: 100%)
  https://www.datacamp.com/blog/best-clawhub-skills
  * tavily-web-search is the most widely installed search skill on ClawHub. It connects to the Tavily API, which is optimized for AI agents rather than human browsers. * githu

### 补充 2

- **Best Openclaw Skills You Should Install (From ClawHub's 500+ Skills)** (relevance: 100%)
  https://www.reddit.com/r/AI_Agents/comments/1r2u356/best_openclaw_skills_you_should_install_from/
  [Skip to main content](https://www.reddit.com/r/AI_Agents/comments/1r2u356/best_openclaw_skills_you_shoul

### 补充 3

- **OpenClaw Setup Guide: 25 Tools + 53 Skills Explained | WenHao Yu** (relevance: 100%)
  https://yu-wenhao.com/en/blog/openclaw-tools-skills-tutorial/
  ![Image 3: OpenClaw concentric circle architecture: Layer 1 core tools (read, write, exec), Layer 2 advanced tools (browser, memory, automation),

### 补充 4

- **Hundreds of Malicious Skills Found in OpenClaw's ClawHub** (relevance: 100%)
  https://www.esecurityplanet.com/threats/hundreds-of-malicious-skills-found-in-openclaws-clawhub/
  Link to What is Network Security? Learn about the fundamentals of network security and how to protect your organizatio

### 补充 5

OpenClaw skill sharing community includes LobeHub and GitHub repositories for skill installation and reviews. Essential skills are available for project management and coding assistance. The community provides extensive documentation and support.

## 本章小结

- **ClawHub 平台简介**：了解了 ClawHub 作为 OpenClaw 技能市场的定位、架构和核心功能。
- **浏览与搜索技能**：掌握了通过网页和命令行两种方式发现技能，熟悉了搜索参数和分类体系。
- **安装与管理技能**：学会了技能的安装、配置、更新与卸载操作。
- **发布技能到 ClawHub**：掌握了从 SKILL.md 编写、格式验证到一键发布的完整流程。
- **社区协作**：了解了 Fork → PR 的开源协作方式和最佳实践。
- 遇到问题时，善用 `openclaw doctor` 进行诊断，或查阅本章 FAQ 部分。

> 下一章：[06-自动化命令与脚本集成](06-自动化命令与脚本集成.md)

---
[⬅️ 上一章：Skills 安装与管理实践](04-Skills%20安装与管理实践.md) | [📑 目录](README.md) | [➡️ 下一章：自动化命令与脚本集成](06-自动化命令与脚本集成.md)
---
