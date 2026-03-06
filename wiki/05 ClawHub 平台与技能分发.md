# 🏪 ClawHub 平台与技能分发

> **难度**: ⭐⭐ 中级 | **预计阅读**: 3 分钟

---

## 📋 本章要点

- ClawHub（skills.sh）是 OpenClaw 官方技能市场，集浏览、安装、发布、评分于一体
- 支持网页浏览和命令行搜索两种技能发现方式
- 技能详情包含版本、安装量、评分、依赖等完整信息
- 发布技能需通过三阶段：准备（SKILL.md + 测试）→ 验证（validate + vet）→ 提交（publish）
- 所有公开 Skill 都经自动安全扫描 + 人工复审
- 支持 Fork、Issue、Pull Request 等社区协作方式
- 技能分类覆盖搜索、办公、开发、AI、安全、通讯等领域

## 🔑 核心知识

ClawHub 平台架构分三层：前端展示（skills.sh 网站）、API 服务（Skills CLI 工具）和后端审核（skill-vetter 自动扫描 + 人工复审）。用户既可以通过网站按分类/热度/更新时间浏览技能，也可以用 `npx skills find` 快速搜索。安装只需 `npx skills install <name>`，支持指定版本号。

发布自定义 Skill 到 ClawHub 的流程为：先在技能目录执行 `npx skills init` 生成 `.skillrc` 配置，然后用 `npx skills validate` 校验格式、`npx skills vet .` 运行安全审查，最后 `npx skills publish` 提交。发布前需确保 SKILL.md 包含完整的 frontmatter、README 包含使用说明、所有脚本可独立运行、依赖已声明。

## 💻 关键命令/代码

```bash
# 搜索和安装
npx skills find "automation" --sort stars
npx skills install tavily-search@1.2.0

# 发布技能到 ClawHub
npx skills init        # 初始化发布配置
npx skills validate    # 格式校验
npx skills publish     # 提交发布
```

## 🔗 相关章节

- [[03 Skills 插件体系与批量开发]] — Skill 开发规范
- [[04 Skills 安装与管理实践]] — 安装与安全管理
- [[11 高级场景 第三方平台集成]] — 高级集成场景

---

> 📖 [阅读完整章节](https://github.com/zxk-git/openclaw-tutorial-auto/blob/main/05-ClawHub%20平台与技能分发.md)
