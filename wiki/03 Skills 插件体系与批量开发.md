# 🧩 Skills 插件体系与批量开发

> **难度**: ⭐⭐ 中级 | **预计阅读**: 4 分钟

---

## 📋 本章要点

- Skills 是 OpenClaw 的核心扩展机制，Agent 通过触发词自动匹配并调用
- 每个 Skill 是一个独立目录，核心文件为 SKILL.md（必需）和 _meta.json（必需）
- SKILL.md 使用 YAML frontmatter + Markdown 正文，定义名称、版本、触发词等
- 内置技能涵盖搜索引擎、Agent 框架、办公集成、文件工具等 8 大分类
- 批量管理通过脚本遍历 `~/.openclaw/workspace/skills/` 目录实现
- 支持 Skill 健康检查、frontmatter 校验、触发词检测等自动化质量保证
- Skill 开发遵循：创建目录 → 编写 SKILL.md → 写 _meta.json → 测试验证的流程

## 🔑 核心知识

Skills 体系的工作流程为：Agent 接收用户请求 → 意图识别匹配触发词 → 加载 SKILL.md 解析指令 → 执行脚本/工具/MCP → 返回结果。每个 Skill 目录包含 `SKILL.md`（入口与说明）、`_meta.json`（安装元数据），以及可选的 `scripts/`、`templates/`、`hooks/` 等子目录。

编写 SKILL.md 时，frontmatter 必须包含 `name`、`version`、`description`、`author` 四个字段；触发词应使用明确的动作词（避免"帮我"这类宽泛表达）；正文应包含快速开始、使用方法、配置和依赖声明。批量管理多 Skill 时，可编写 shell 脚本遍历 skills 目录，提取版本号、检查 frontmatter 完整性和代码示例有效性。

## 💻 关键命令/代码

```bash
# 创建新 Skill
mkdir -p ~/.openclaw/workspace/skills/my-skill
cd ~/.openclaw/workspace/skills/my-skill

# 批量列出所有 Skill 及版本
for dir in ~/.openclaw/workspace/skills/*/; do
  name=$(basename "$dir")
  version=$(grep -oP 'version:\s*\K[\d.]+' "$dir/SKILL.md" | head -1)
  echo "$name: v${version:-unknown}"
done
```

## 🔗 相关章节

- [[04 Skills 安装与管理实践]] — 安装与安全审查
- [[05 ClawHub 平台与技能分发]] — 技能市场与发布
- [[06 自动化命令与脚本集成]] — 脚本集成能力

---

> 📖 [阅读完整章节](https://github.com/zxk-git/openclaw-tutorial-auto/blob/main/03-Skills%20插件体系与批量开发.md)
