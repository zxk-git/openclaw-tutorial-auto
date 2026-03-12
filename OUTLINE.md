<div align="center">

# 🦞 OpenClaw 实战教程 · 完整大纲

**从零到精通 · 21 章 + 18 Skills 教程 · 覆盖 OpenClaw 全能力域**

[![Chapters](https://img.shields.io/badge/chapters-21-blue?style=for-the-badge)](README.md)
[![Skills](https://img.shields.io/badge/skills-18-ff69b4?style=for-the-badge)](skills-tutorials/README.md)
[![Quality](https://img.shields.io/badge/quality-98.1%2F100-brightgreen?style=for-the-badge)](.)

</div>

> **版本**: v5.0 &nbsp;|&nbsp; **总章节**: 21 + 18 Skills 教程 &nbsp;|&nbsp; **持续自动更新**
>
> 💡 **图标说明** &nbsp; 📖 理论讲解 &nbsp;|&nbsp; 💻 实战操作 &nbsp;|&nbsp; 🧪 练习任务

---

## 🗺️ 学习路线图

```
  ┌──────────────────────────────────────────────────────────────────┐
  │                    🦞 OpenClaw 学习路线                          │
  ├──────────┬──────────┬──────────────┬─────────────────────────────┤
  │  🟢 入门  │  🔵 核心  │   🟣 进阶     │       🔴 专家              │
  │  Ch 1-5  │  Ch 6-10 │  Ch 11-15   │       Ch 16-21             │
  │  ~5 小时  │  ~8 小时  │  ~10 小时    │       ~12 小时             │
  ├──────────┼──────────┼──────────────┼─────────────────────────────┤
  │ 安装部署  │ 自动化    │ 第三方集成   │  MCP / 浏览器              │
  │ Skills   │ 飞书集成  │ 安全/Memory  │  性能优化 / 企业部署        │
  │ ClawHub  │ 多 Agent   │ CI/CD       │  生态展望 / 多飞书实战      │
  └──────────┴──────────┴──────────────┴─────────────────────────────┘
```

---

## 🟢 第一部分：基础入门（第 1-5 章）

<table>
<tr><th width="40">#</th><th width="280">章节</th><th width="60">难度</th><th>子节概览</th></tr>

<tr>
<td align="center"><b>01</b></td>
<td>

[**OpenClaw 基础介绍与安装**](01-基础介绍与安装.md)

</td>
<td align="center">⭐</td>
<td>

- 📖 什么是 OpenClaw：定位、核心理念与适用场景
- 📖 系统架构总览：Gateway → Agent → Skills 三层模型
- 📖 与同类工具对比：AutoGPT / MetaGPT / Dify
- 💻 安装：curl 一键安装 / 手动安装 / Docker 部署
- 💻 首次运行与验证：`openclaw --version`、`openclaw status`
- 📖 目录结构说明：`~/.openclaw/` 各子目录用途
- 🧪 安装并截图验证，探索 `~/.openclaw/` 目录

</td>
</tr>

<tr>
<td align="center"><b>02</b></td>
<td>

[**部署与环境初始化**](02-部署与环境初始化.md)

</td>
<td align="center">⭐</td>
<td>

- 📖 部署模式选择：本地 / 云服务器 / Docker Compose
- 💻 服务端部署全流程（Ubuntu / CentOS / macOS）
- 💻 openclaw.json 核心配置详解
- 📖 网络安全：端口管理、防火墙、HTTPS
- 💻 设备身份与认证：device.json、device-auth.json
- 💻 多环境配置：开发 / 测试 / 生产环境切换
- 📖 systemd / pm2 持久化运行
- 🧪 在云服务器上完成完整部署

</td>
</tr>

<tr>
<td align="center"><b>03</b></td>
<td>

[**Skills 插件体系与批量开发**](03-Skills 插件体系与批量开发.md)

</td>
<td align="center">⭐⭐</td>
<td>

- 📖 Skills 体系设计理念
- 📖 Skill 目录结构规范：_meta.json / SKILL.md / 脚本
- 💻 SKILL.md 编写指南
- 💻 _meta.json 配置详解
- 💻 从零编写第一个 Skill：hello-world 实例
- 💻 Skill 脚本开发：Python / Node.js / Shell
- 💻 批量开发模式：工作流驱动
- 📖 Skill 生命周期：开发 → 测试 → 发布 → 维护
- 🧪 开发「天气查询」Skill 并本地测试

</td>
</tr>

<tr>
<td align="center"><b>04</b></td>
<td>

[**Skills 安装与管理实践**](04-Skills 安装与管理实践.md)

</td>
<td align="center">⭐⭐</td>
<td>

- 💻 从 ClawHub 安装 Skill
- 💻 本地 Skill 安装：路径安装与软链接
- 💻 版本管理：升级、回滚、锁定
- 💻 依赖管理：Skill 间 / 系统 / Python 包
- 💻 Skill 启用与禁用：按需加载
- 📖 排查安装失败：常见错误与解决
- 💻 批量管理命令：list / update / remove
- 🧪 安装 3 个社区 Skill 并验证

</td>
</tr>

<tr>
<td align="center"><b>05</b></td>
<td>

[**ClawHub 平台与技能分发**](05-ClawHub 平台与技能分发.md)

</td>
<td align="center">⭐⭐</td>
<td>

- 📖 ClawHub 生态概述
- 💻 发布 Skill 到 ClawHub：打包、校验、上传
- 💻 版本管理与更新推送
- 📖 技能市场：分类、搜索、评价
- 📖 社区协作：Fork、PR、Issue 工作流
- 💻 私有仓库与团队 Skill 共享
- 🧪 将自己开发的 Skill 发布到 ClawHub

</td>
</tr>

</table>

---

## 🔵 第二部分：核心能力（第 6-10 章）

<table>
<tr><th width="40">#</th><th width="280">章节</th><th width="60">难度</th><th>子节概览</th></tr>

<tr>
<td align="center"><b>06</b></td>
<td>

[**自动化命令与脚本集成**](06-自动化命令与脚本集成.md)

</td>
<td align="center">⭐⭐⭐</td>
<td>

- 📖 OpenClaw CLI 命令体系全览
- 💻 Cron 定时任务：创建、管理、日志查看
- 💻 Hook 系统：事件触发自动化
- 💻 脚本集成：Shell / Python / Node.js
- 💻 管道与链式执行：多步骤任务编排
- 📖 批处理模式：大批量并发管理
- 💻 环境变量与密钥注入
- 🧪 创建每日自动报告生成任务

</td>
</tr>

<tr>
<td align="center"><b>07</b></td>
<td>

[**飞书集成与消息自动化**](07-飞书集成与消息自动化.md)

</td>
<td align="center">⭐⭐⭐</td>
<td>

- 📖 飞书集成架构：OpenClaw ↔ 飞书开放平台
- 💻 飞书应用创建与权限配置
- 💻 凭证配置：pairing.json 与 credential
- 💻 消息收发：文本、富文本、卡片
- 💻 群聊自动化：自动回复、定时通知
- 💻 Webhook 与事件订阅
- 📖 飞书机器人最佳实践
- 🧪 搭建飞书群自动答疑机器人

</td>
</tr>

<tr>
<td align="center"><b>08</b></td>
<td>

[**单 Gateway 多 Agent 配置与管理**](08-单 Gateway 多 Agent 配置与管理.md)

</td>
<td align="center">⭐⭐⭐</td>
<td>

- 📖 多 Agent 架构设计
- 💻 Agent 配置：openclaw.json agents 字段
- 💻 会话路由规则：关键词 / 模型 / 优先级
- 💻 资源隔离：Memory / Skills / Credential
- 📖 Agent 间通信与协作
- 💻 模型混用：GPT-4o / Claude / 本地
- 💻 Agent 健康监控与自动重启
- 🧪 配置主 Agent + 助手 Agent 双角色

</td>
</tr>

<tr>
<td align="center"><b>09</b></td>
<td>

[**故障排查与日志分析**](09-故障排查与日志分析.md)

</td>
<td align="center">⭐⭐</td>
<td>

- 📖 日志体系全览：层级、存储、格式
- 💻 日志查看命令：`openclaw logs` 系列
- 💻 常见错误分类与解决
- 💻 诊断工具：`openclaw doctor`
- 📖 性能分析：慢请求定位、资源监控
- 💻 日志告警配置：关键错误推送飞书
- 📖 事故复盘：日志 → 根因 → 修复 → 预防
- 🧪 模拟故障并完成完整排查

</td>
</tr>

<tr>
<td align="center"><b>10</b></td>
<td>

[**持续集成与知识库同步**](10-持续集成与知识库同步.md)

</td>
<td align="center">⭐⭐⭐</td>
<td>

- 📖 CI/CD 在 Agent 场景的应用
- 💻 GitHub Actions 集成：测试 + 部署
- 💻 知识库管理：导入、存储、版本控制
- 💻 自动同步机制：定时抓取外部知识源
- 💻 增量更新与冲突处理
- 📖 质量保障：去重、过期检测、一致性
- 🧪 配置 GitHub Actions 自动测试

</td>
</tr>

</table>

---

## 🟣 第三部分：高级进阶（第 11-15 章）

<table>
<tr><th width="40">#</th><th width="280">章节</th><th width="60">难度</th><th>子节概览</th></tr>

<tr>
<td align="center"><b>11</b></td>
<td>

[**高级场景：第三方平台集成**](11-高级场景-第三方平台集成.md)

</td>
<td align="center">⭐⭐⭐⭐</td>
<td>

- 📖 集成架构模式：Webhook / API / MCP / SDK
- 💻 GitHub 集成：Issue 自动处理、PR 审查
- 💻 Notion 集成：文档同步、数据库操作
- 💻 Telegram / Discord 集成
- 💻 企业微信集成
- 💻 自定义 Webhook 接收器
- 📖 集成安全最佳实践
- 🧪 GitHub Issue 到飞书群自动转发

</td>
</tr>

<tr>
<td align="center"><b>12</b></td>
<td>

[**实践案例与常见问题**](12-实践案例与常见问题.md)

</td>
<td align="center">⭐⭐⭐</td>
<td>

- 💻 案例 1：智能知识助手（多轮对话 + 检索）
- 💻 案例 2：运维监控机器人（告警 → 诊断 → 修复）
- 💻 案例 3：内容审核与自动发布流水线
- 💻 案例 4：跨平台数据同步 Agent
- 💻 案例 5：团队日报/周报自动生成
- 📖 FAQ：50+ 高频问题与解决方案
- 📖 反模式：常见错误用法与改进
- 🧪 选择一个案例进行完整实现

</td>
</tr>

<tr>
<td align="center"><b>13</b></td>
<td>

[**教程自动更新与仓库维护**](13-教程自动更新与仓库维护.md)

</td>
<td align="center">⭐⭐</td>
<td>

- 📖 自动化维护理念：让教程自己进化
- 💻 Cron 调度配置：搜索、生成、优化、推送
- 💻 质量检测系统：六维度评估模型
- 💻 自动 Git 提交与推送
- 📖 版本管理策略：语义化版本、变更日志
- 💻 健康检查与告警
- 🧪 为自己的项目配置自动维护流水线

</td>
</tr>

<tr>
<td align="center"><b>14</b></td>
<td>

[**安全与权限管理**](14-安全与权限管理.md)

</td>
<td align="center">⭐⭐⭐</td>
<td>

- 📖 OpenClaw 安全模型：设备认证、凭证隔离、权限分级
- 💻 Credential 管理：添加、更新、加密存储
- 💻 执行审批机制：exec-approvals.json
- 💻 Skill 权限声明与沙箱隔离
- 📖 网络安全：TLS、IP 白名单、速率限制
- 💻 敏感信息保护：Vault 集成
- 📖 安全审计日志：config-audit.jsonl
- 🧪 配置安全策略并验证权限隔离

</td>
</tr>

<tr>
<td align="center"><b>15</b></td>
<td>

[**Memory 记忆系统深入**](15-Memory 记忆系统深入.md)

</td>
<td align="center">⭐⭐⭐</td>
<td>

- 📖 Memory 系统设计：短期 / 长期 / 工作记忆
- 📖 记忆存储格式：Markdown 文件规范
- 💻 主动记忆管理：创建、查询、更新、删除
- 💻 记忆命名规范与分类策略
- 💻 跨会话记忆持久化
- 📖 记忆检索机制：语义匹配、关键词、时间衰减
- 💻 记忆合并与清理：防止膨胀
- 📖 记忆在 Agent 决策中的作用
- 🧪 设计并实现结构化记忆系统

</td>
</tr>

</table>

---

## 🔴 第四部分：专家实战（第 16-20 章）

<table>
<tr><th width="40">#</th><th width="280">章节</th><th width="60">难度</th><th>子节概览</th></tr>

<tr>
<td align="center"><b>16</b></td>
<td>

[**MCP 工具协议与自定义集成**](16-MCP 工具协议与自定义集成.md)

</td>
<td align="center">⭐⭐⭐⭐</td>
<td>

- 📖 MCP (Model Context Protocol) 概述与规范
- 📖 MCP 与传统 API 的区别
- 💻 使用内置 MCP 工具：GitHub、文件系统、搜索
- 💻 开发自定义 MCP Server：Node.js / Python SDK
- 💻 MCP Server 注册与配置：mcporter.json
- 💻 MCP 工具调试与测试
- 📖 MCP 生态：社区工具集合
- 🧪 开发并注册一个自定义 MCP 工具

</td>
</tr>

<tr>
<td align="center"><b>17</b></td>
<td>

[**浏览器自动化与网页交互**](17-浏览器自动化与网页交互.md)

</td>
<td align="center">⭐⭐⭐</td>
<td>

- 📖 Browser Relay 架构：Agent → Relay → Browser
- 💻 Browser Relay 配置与启动
- 💻 网页浏览与信息抓取
- 💻 表单填写与自动化操作
- 💻 截图与页面分析
- 📖 反爬策略与合规使用
- 💻 浏览器驱动的自动化任务
- 🧪 实现自动化网页信息采集 Agent

</td>
</tr>

<tr>
<td align="center"><b>18</b></td>
<td>

[**性能优化与规模化部署**](18-性能优化与规模化部署.md)

</td>
<td align="center">⭐⭐⭐⭐</td>
<td>

- 📖 性能瓶颈分析：Token 消耗、API 延迟、并发
- 💻 模型选择策略：成本 vs 质量 vs 速度
- 💻 缓存机制：请求缓存、知识库缓存
- 💻 并发任务管理：队列、限流、优先级
- 📖 大规模部署：多节点 Gateway、负载均衡
- 💻 监控与告警：Prometheus / Grafana
- 💻 成本控制：Token 预算、使用量分析
- 🧪 对现有部署进行性能测试与优化

</td>
</tr>

<tr>
<td align="center"><b>19</b></td>
<td>

[**团队协作与企业部署**](19-团队协作与企业部署.md)

</td>
<td align="center">⭐⭐⭐</td>
<td>

- 📖 团队使用模式：共享 Agent vs 个人 Agent
- 💻 多用户权限配置
- 💻 团队知识库管理：共享 vs 私有
- 💻 审批流与变更管理
- 📖 企业级安全合规：数据保护、审计、备份
- 💻 私有化部署方案：离线安装、私有模型
- 📖 团队最佳实践：规范、培训、文化
- 🧪 模拟配置 3 人团队 OpenClaw 环境

</td>
</tr>

<tr>
<td align="center"><b>20</b></td>
<td>

[**OpenClaw 生态与未来展望**](20-OpenClaw 生态与未来展望.md)

</td>
<td align="center">⭐⭐</td>
<td>

- 📖 OpenClaw 开源生态全景
- 📖 社区参与指南：贡献代码、文档、Skill
- 📖 版本演进路线图：历史与未来规划
- 📖 AI Agent 行业趋势：自主 Agent、Multi-Agent
- 📖 与其他 Agent 框架的互操作
- 💻 从用户到贡献者：提交你的第一个 PR
- 🧪 提交一个 Skill 或文档贡献

</td>
</tr>

</table>

---

## 🛠️ 附录：实战专题

<table>
<tr><th width="40">#</th><th width="280">章节</th><th width="60">难度</th><th>子节概览</th></tr>

<tr>
<td align="center"><b>21</b></td>
<td>

[**多飞书多 Agent 实战配置**](21-多飞书多Agent实战配置.md)

</td>
<td align="center">⭐⭐⭐⭐</td>
<td>

- 💻 多飞书 App 配置：独立应用创建与权限
- 💻 独立 Agent 创建：飞书 App ↔ Agent 绑定
- 💻 路由绑定：消息路由规则配置
- 💻 工作空间隔离：Agent 间数据隔离策略
- 🧪 配置 2 个飞书 App + 2 个独立 Agent

</td>
</tr>

</table>

---

## 🧩 Skills 安装与使用教程

> 📖 **[Skills 教程合集](skills-tutorials/README.md)** — 18 个已安装 Skills 的完整教程

<table>
<tr><th width="40">#</th><th width="220">Skill</th><th width="120">分类</th><th>教程链接</th></tr>
<tr><td>01</td><td>McPorter</td><td>🔧 MCP 工具</td><td><a href="skills-tutorials/01-mcporter.md">查看教程</a></td></tr>
<tr><td>02</td><td>Complex Task Automator</td><td>🔧 任务自动化</td><td><a href="skills-tutorials/02-complex-task-automator.md">查看教程</a></td></tr>
<tr><td>03</td><td>DDG Web Search</td><td>🔍 搜索引擎</td><td><a href="skills-tutorials/03-ddg-web-search.md">查看教程</a></td></tr>
<tr><td>04</td><td>Exa Web Search</td><td>🔍 搜索引擎</td><td><a href="skills-tutorials/04-exa-web-search.md">查看教程</a></td></tr>
<tr><td>05</td><td>File Search</td><td>🔍 搜索工具</td><td><a href="skills-tutorials/05-file-search.md">查看教程</a></td></tr>
<tr><td>06</td><td>Find Skills</td><td>🧩 技能管理</td><td><a href="skills-tutorials/06-find-skills.md">查看教程</a></td></tr>
<tr><td>07</td><td>GitHub</td><td>🔗 平台集成</td><td><a href="skills-tutorials/07-github.md">查看教程</a></td></tr>
<tr><td>08</td><td>GoG</td><td>🔗 平台集成</td><td><a href="skills-tutorials/08-gog.md">查看教程</a></td></tr>
<tr><td>09</td><td>Markdown Converter</td><td>📄 内容处理</td><td><a href="skills-tutorials/09-markdown-converter.md">查看教程</a></td></tr>
<tr><td>10</td><td>Memory</td><td>🧠 Agent 增强</td><td><a href="skills-tutorials/10-memory.md">查看教程</a></td></tr>
<tr><td>11</td><td>Multi Search Engine</td><td>🔍 搜索引擎</td><td><a href="skills-tutorials/11-multi-search-engine.md">查看教程</a></td></tr>
<tr><td>12</td><td>Notion</td><td>🔗 平台集成</td><td><a href="skills-tutorials/12-notion.md">查看教程</a></td></tr>
<tr><td>13</td><td>PowerPoint PPTX</td><td>📄 内容处理</td><td><a href="skills-tutorials/13-powerpoint-pptx.md">查看教程</a></td></tr>
<tr><td>14</td><td>Proactive Agent</td><td>🧠 Agent 增强</td><td><a href="skills-tutorials/14-proactive-agent.md">查看教程</a></td></tr>
<tr><td>15</td><td>Self-Improving Agent</td><td>🧠 Agent 增强</td><td><a href="skills-tutorials/15-self-improving-agent.md">查看教程</a></td></tr>
<tr><td>16</td><td>Skill Vetter</td><td>🛡️ 安全审核</td><td><a href="skills-tutorials/16-skill-vetter.md">查看教程</a></td></tr>
<tr><td>17</td><td>Summarize</td><td>📄 内容处理</td><td><a href="skills-tutorials/17-summarize.md">查看教程</a></td></tr>
<tr><td>18</td><td>Tavily Search</td><td>🔍 搜索引擎</td><td><a href="skills-tutorials/18-tavily-search.md">查看教程</a></td></tr>
</table>

---

## 📎 附录索引

| 附录 | 内容 |
|------|------|
| **A** | OpenClaw CLI 命令速查表 |
| **B** | 配置文件参考（openclaw.json 全字段说明） |
| **C** | Skill 开发模板（Python / Node.js / Shell） |
| **D** | 常用第三方集成配置速查 |
| **E** | [术语表](wiki/术语表.md) |

---

<div align="center">
<sub>📖 <a href="README.md">返回主页</a> · 由 OpenClaw Agent 自动生成和维护</sub>
</div>
