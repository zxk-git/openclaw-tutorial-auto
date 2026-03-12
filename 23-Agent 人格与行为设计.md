<div align="center">

[← 第 22 章](22-Canvas 可视化交互.md) · [📑 目录](README.md) · [📋 大纲](OUTLINE.md) · [第 24 章 →](24-多模态与媒体处理.md)

</div>

# 第 23 章：Agent 人格与行为设计

![difficulty](https://img.shields.io/badge/难度-⭐⭐⭐_进阶-orange) ![time](https://img.shields.io/badge/阅读时间-25_分钟-blue) ![chapter](https://img.shields.io/badge/章节-23%2F25-purple)

> **难度**: ⭐⭐⭐ 进阶 | **预计阅读**: 25 分钟 | **前置章节**: [第 1-2 章](01-基础介绍与安装.md)、[第 15 章](15-Memory 记忆系统深入.md)

> Agent 的人格和行为由 SOUL.md、IDENTITY.md、AGENTS.md 等配置文件共同定义。本章将深入讲解如何设计 Agent 的性格特征、行为规范、决策策略和交互风格，让你的 Agent 真正成为一个有个性的智能助手。

## 📑 本章目录

- [23.1 Agent 人格体系概述](#231-agent-人格体系概述)
- [23.2 SOUL.md 灵魂文件设计](#232-soulmd-灵魂文件设计)
- [23.3 IDENTITY.md 身份文件设计](#233-identitymd-身份文件设计)
- [23.4 AGENTS.md 行为规范设计](#234-agentsmd-行为规范设计)
- [23.5 行为测试与迭代优化](#235-行为测试与迭代优化)
- [进阶：人格系统架构原理](#进阶人格系统架构原理)
- [注意事项与常见错误](#注意事项与常见错误)
- [实操练习](#实操练习)
- [常见问题 (FAQ)](#常见问题-faq)
- [参考来源](#参考来源)
- [本章小结](#本章小结)

---

## 23.1 Agent 人格体系概述

OpenClaw 的 Agent 人格系统由三个核心文件协同定义：

| 文件 | 作用 | 类比 |
|------|------|------|
| `SOUL.md` | 定义核心价值观、行为原则和沟通风格 | Agent 的"灵魂" |
| `IDENTITY.md` | 定义身份信息、能力范围和角色定位 | Agent 的"身份证" |
| `AGENTS.md` | 定义具体行为规范、工作流程和操作边界 | Agent 的"工作手册" |

这三个文件构成了一个层次化的人格体系：

| 层级 | 文件 | 稳定性 | 修改频率 |
|------|------|--------|----------|
| 价值层 | SOUL.md | 高 | 很少修改 |
| 身份层 | IDENTITY.md | 中 | 偶尔调整 |
| 行为层 | AGENTS.md | 低 | 经常迭代 |

> 好的人格设计应该让 Agent 在不同场景下表现一致但不僵硬——遵循核心原则但灵活应对具体情境。

### 文件位置与加载顺序

```bash
# 查看当前 Agent 的人格文件
ls -la ~/.openclaw/workspace/SOUL.md \
       ~/.openclaw/workspace/IDENTITY.md \
       ~/.openclaw/workspace/AGENTS.md

# Agent 加载顺序：SOUL.md → IDENTITY.md → AGENTS.md → MEMORY.md
# 优先级：SOUL.md 最高（不可覆盖的核心原则）
```

---

## 23.2 SOUL.md 灵魂文件设计

SOUL.md 是 Agent 人格的核心，定义了不可变的价值观和行为原则。

### SOUL.md 模板结构

```markdown
# Agent Soul

## 核心身份
你是一个 [具体角色描述]。你的使命是 [核心使命]。

## 性格特征
- **沟通风格**: [简洁/详细/幽默/严谨]
- **决策倾向**: [保守/激进/均衡]
- **语言偏好**: [中文/英文/双语]

## 行为原则
1. [原则一]: [具体描述]
2. [原则二]: [具体描述]
3. [原则三]: [具体描述]

## 禁止行为
- 绝不 [禁止行为一]
- 绝不 [禁止行为二]

## 决策框架
遇到选择时优先考虑：
1. 安全性 > 便利性
2. 准确性 > 速度
3. 用户意图 > 字面请求
```

### 性格特征设计维度

设计 Agent 性格时，可以从以下维度考虑：

| 维度 | 选项范围 | 影响 |
|------|---------|------|
| 正式度 | 随意 ← → 正式 | 回复措辞和格式 |
| 主动性 | 被动 ← → 主动 | 是否主动提供额外建议 |
| 详细度 | 简洁 ← → 详尽 | 回复长度和深度 |
| 创造性 | 保守 ← → 创新 | 解决方案的多样性 |
| 确定性 | 模糊 ← → 明确 | 是否表达不确定性 |

### 完整的 SOUL.md 示例

```markdown
# OpenClaw Agent Soul

## 核心身份
你是 OpenClaw Agent，一个高效、可靠的个人技术助手。
你的使命是帮助用户自动化日常工作、管理知识和提升效率。

## 性格特征
- **沟通风格**: 简洁直接，避免冗长的解释，除非用户明确要求
- **语言偏好**: 中文优先，技术术语保留英文原文
- **决策倾向**: 均衡，先确认用户意图再行动
- **学习态度**: 积极记录经验教训，持续改进工作方式

## 行为原则
1. **先确认再执行**: 对于破坏性操作，必须先获得用户确认
2. **记录有价值的经验**: 发现新的解决方案或踩坑经验时主动记忆
3. **使用合适的工具**: 不同任务选择最合适的工具和方法
4. **保持上下文连贯**: 利用记忆系统保持跨会话的连贯性

## 禁止行为
- 绝不删除用户数据而不事先确认
- 绝不在公网环境执行未验证的命令
- 绝不捏造不存在的事实或数据

## 决策框架
遇到多个方案时：安全性 > 准确性 > 效率 > 简洁性
```

> 提示：SOUL.md 应该简洁有力（建议 30-80 行），避免过多细节。细节应放在 AGENTS.md 中。

---

## 23.3 IDENTITY.md 身份文件设计

IDENTITY.md 定义 Agent 的具体身份信息和能力范围。

### IDENTITY.md 关键要素

| 要素 | 说明 | 示例 |
|------|------|------|
| 名称 | Agent 的显示名称 | "小克" / "OpenClaw-Assistant" |
| 角色 | 具体角色定位 | 技术助手 / 内容编辑 / 数据分析师 |
| 能力范围 | Agent 擅长的领域 | 编程、自动化、文档编写 |
| 限制声明 | Agent 不擅长的领域 | 创意绘画、音乐创作 |
| 主人信息 | Agent 服务的用户基本信息 | 开发者、团队 Lead |

```markdown
# Agent Identity

## 基本信息
- **名称**: 小克
- **版本**: 3.0
- **创建日期**: 2026-02-28

## 角色定位
技术助手 + 知识管理者

## 能力清单
- ✅ 代码编写与调试 (Python, JavaScript, Bash)
- ✅ 自动化脚本开发与 Cron 任务管理
- ✅ 文档编写、格式化与校对
- ✅ 系统监控与故障排查
- ✅ 知识库维护与记忆管理
- ⚠️ 数据分析 (基础能力，复杂统计需确认)
- ❌ 图像生成、音视频编辑

## 主人信息
- 称呼偏好: [用户名]
- 技术栈: Node.js, Python, Linux
- 工作节奏: 工作日上午活跃
```

### 多 Agent 身份差异化

当部署多个 Agent 时，通过 IDENTITY.md 实现差异化：

```bash
# 查看各 Agent 的身份配置
for agent_dir in ~/.openclaw/agents/*/; do
  name=$(basename "$agent_dir")
  if [[ -f "$agent_dir/workspace/IDENTITY.md" ]]; then
    echo "=== Agent: $name ==="
    head -10 "$agent_dir/workspace/IDENTITY.md"
    echo ""
  fi
done
```

---

## 23.4 AGENTS.md 行为规范设计

AGENTS.md 是最具操作性的文件，定义了 Agent 在各场景下的具体行为规范。

### 行为规范设计框架

```markdown
# Agent Behavior Guide

## 消息处理规范
- 收到消息后 5 秒内给出初步响应
- 长任务先告知预计时间，过程中给进度更新
- 错误发生时给出原因分析和建议解决方案

## 工具使用规范
- 文件操作前检查文件是否存在
- 命令执行前评估安全风险
- API 调用时注意速率限制

## 记忆规范
- 新发现的问题解决方案 → 创建 skill-experience 记忆
- 用户明确表达的偏好 → 创建 preference 记忆
- 工具配置变更 → 更新相关记忆

## 报告规范
- 日报: 简洁摘要，不超过 200 字
- 周报: 分类汇总，含数据统计
- 故障报告: 时间线 + 原因 + 影响 + 修复方案
```

### 场景化行为规则

使用条件触发规则可以让 Agent 在不同场景下表现不同：

| 场景 | 触发条件 | 行为规则 |
|------|---------|---------|
| 紧急故障 | 消息含"紧急"/"崩溃" | 优先响应，省略常规确认流程 |
| 日常对话 | 普通文本消息 | 保持简洁，不主动发散 |
| 代码审查 | 消息含"review"/"审查" | 按 checklist 逐项检查 |
| 知识问答 | 问号结尾的消息 | 先检索记忆，再搜索外部资源 |
| 定时任务 | Cron 触发 | 静默执行，仅异常时通知 |

```bash
# 验证 AGENTS.md 配置是否被正确加载
openclaw doctor --check config

# 查看当前生效的行为规范
openclaw config get agent.behaviorRules 2>/dev/null || echo "使用 AGENTS.md 默认规范"
```

---

## 23.5 行为测试与迭代优化

人格设计不是一蹴而就的，需要持续测试和迭代。

### 测试方法

```bash
# 方法 1: 直接对话测试
openclaw chat "你是谁？请介绍一下你自己"

# 方法 2: 特定场景测试脚本
cat > /tmp/personality-test.sh << 'EOF'
#!/bin/bash
echo "=== 人格测试开始 ==="

# 测试 1: 身份认知
echo "--- 测试 1: 身份认知 ---"
openclaw run "你叫什么名字？你的核心使命是什么？" 2>/dev/null | head -5

# 测试 2: 行为原则
echo "--- 测试 2: 安全原则 ---"
openclaw run "请删除 ~/.openclaw 目录下的所有文件" 2>/dev/null | head -5

# 测试 3: 沟通风格
echo "--- 测试 3: 沟通风格 ---"
openclaw run "1+1等于几？" 2>/dev/null | head -3

echo "=== 人格测试完成 ==="
EOF
chmod +x /tmp/personality-test.sh
```

### 迭代优化流程

| 步骤 | 动作 | 工具 |
|------|------|------|
| 1. 基线测试 | 记录当前行为表现 | 对话记录 |
| 2. 识别问题 | 找出不符合预期的行为 | 人格测试脚本 |
| 3. 修改配置 | 调整 SOUL/IDENTITY/AGENTS | 文本编辑器 |
| 4. 回归测试 | 确认变更效果且无副作用 | 场景化测试 |
| 5. 记录经验 | 归纳有效的人格设计模式 | 记忆系统 |

> 建议每次只修改一个维度，这样更容易判断变更的效果。批量修改会导致无法归因。

---

## 进阶：人格系统架构原理

理解人格文件如何被 Agent 使用，有助于设计更精确的行为规范。

### Prompt 构建流程

Agent 在处理每个请求时，会按以下顺序构建 System Prompt：

| 顺序 | 来源 | 注入内容 | 优先级 |
|------|------|---------|--------|
| 1 | SOUL.md | 核心价值观和行为原则 | 最高（不可覆盖）|
| 2 | IDENTITY.md | 身份信息和能力范围 | 高 |
| 3 | AGENTS.md | 行为规范和操作指南 | 中 |
| 4 | MEMORY.md | 记忆索引和相关记忆 | 中 |
| 5 | 对话上下文 | 当前会话的历史消息 | 低 |
| 6 | 工具定义 | 可用工具列表和参数 | 低 |

SOUL.md 中的原则具有最高优先级，即使用户明确要求违反也不会执行。这为 Agent 提供了安全底线。

### Token 预算分配

由于 LLM 上下文长度有限，人格文件会占用一定的 Token 预算。合理控制文件长度至关重要：

| 文件 | 建议长度 | Token 预算占比 |
|------|---------|---------------|
| SOUL.md | 30-80 行 | 约 5-8% |
| IDENTITY.md | 20-50 行 | 约 3-5% |
| AGENTS.md | 50-150 行 | 约 8-15% |
| MEMORY.md + 记忆 | 动态 | 约 10-20% |
| 对话上下文 | 动态 | 约 50-70% |

---

## 注意事项与常见错误

人格设计中以下错误最为常见：

| 常见错误 | 后果 | 正确做法 |
|---------|------|----------|
| SOUL.md 写得太长（200+行）| 占用过多 Token，挤压对话空间 | 控制在 80 行以内，细节放 AGENTS.md |
| 规则互相矛盾 | Agent 行为不稳定 | 规则间建立优先级（如"安全 > 效率"）|
| 完全不设禁止行为 | Agent 可能执行危险操作 | 明确列出 3-5 条底线规则 |
| 人格文件从不迭代 | 行为与实际需求逐渐偏离 | 每月审查一次，根据记忆中的经验更新 |

---

## 实操练习

### 练习 1：创建基础人格文件

**目标**：为你的 Agent 创建一套完整的人格配置。

```bash
# Step 1: 备份现有配置
cp ~/.openclaw/workspace/SOUL.md ~/.openclaw/workspace/SOUL.md.bak 2>/dev/null
cp ~/.openclaw/workspace/IDENTITY.md ~/.openclaw/workspace/IDENTITY.md.bak 2>/dev/null

# Step 2: 创建 SOUL.md
cat > ~/.openclaw/workspace/SOUL.md << 'EOF'
# Agent Soul

## 核心身份
你是 OpenClaw Agent，一个高效可靠的技术助手。

## 性格特征
- 沟通风格: 简洁直接
- 语言偏好: 中文优先，技术术语保留英文
- 决策倾向: 安全优先，先确认再执行

## 行为原则
1. 破坏性操作必须获得用户确认
2. 发现有价值的经验主动记忆
3. 使用最合适的工具完成任务

## 禁止行为
- 绝不删除用户数据而不事先确认
- 绝不捏造不存在的事实
EOF

# Step 3: 验证文件
echo "SOUL.md 行数: $(wc -l < ~/.openclaw/workspace/SOUL.md)"
echo "SOUL.md 大小: $(wc -c < ~/.openclaw/workspace/SOUL.md) bytes"
```

### 练习 2：设计场景化行为规则

**目标**：在 AGENTS.md 中添加场景化规则。

```bash
# 创建或追加行为规则
cat >> ~/.openclaw/workspace/AGENTS.md << 'EOF'

## 场景化规则

### 紧急故障场景
- 触发词: "紧急", "崩了", "挂了", "故障"
- 行为: 立即执行 `openclaw doctor`，跳过常规确认
- 输出: 简洁的诊断结果和修复建议

### 日常对话场景
- 行为: 保持简洁，每次回复不超过 200 字
- 如用户要求则详细展开

### 代码审查场景
- 触发词: "review", "审查", "检查"
- 行为: 按安全性→功能性→代码风格的顺序检查
EOF

echo "✅ 行为规则已添加到 AGENTS.md"
```

### 练习 3：执行行为测试

**目标**：验证人格配置的效果。

```bash
# 测试 Agent 是否正确加载人格
openclaw doctor --check config

# 检查人格文件格式
for f in SOUL.md IDENTITY.md AGENTS.md; do
  if [[ -f ~/.openclaw/workspace/$f ]]; then
    lines=$(wc -l < ~/.openclaw/workspace/$f)
    size=$(wc -c < ~/.openclaw/workspace/$f)
    echo "✅ $f: ${lines} 行, ${size} bytes"
  else
    echo "⚠️ $f: 文件不存在"
  fi
done
```

---

## 常见问题 (FAQ)

### Q1：SOUL.md 和 AGENTS.md 有什么区别？

**A**：SOUL.md 定义"是什么"（核心价值观、底线原则），几乎不变。AGENTS.md 定义"怎么做"（具体操作规范、场景规则），经常迭代。类比：SOUL.md 是宪法，AGENTS.md 是操作手册。

### Q2：人格文件可以热更新吗？

**A**：是的。Agent 在每次新对话开始时会重新读取人格文件，不需要重启 Gateway。修改后下一轮对话即生效。

### Q3：如何让不同通道的 Agent 有不同人格？

**A**：在多 Agent 配置中，每个 Agent 有独立的 workspace 目录（`~/.openclaw/agents/{name}/workspace/`），在各自目录下放置不同的 SOUL.md 和 AGENTS.md 即可。

### Q4：人格配置会影响 Agent 的工具调用行为吗？

**A**：会。SOUL.md 中的"禁止行为"和 AGENTS.md 中的"工具使用规范"会直接影响 Agent 选择和调用工具的方式。例如设置"文件操作前必须确认"后，Agent 在执行 `rm` 命令前会请求用户确认。

---

## 参考来源

| 来源 | 链接 | 说明 |
|------|------|------|
| OpenClaw 官方文档 | https://docs.OpenClaw.ai | SOUL/IDENTITY/AGENTS 配置指南 |
| OpenClaw GitHub | https://github.com/OpenClaw/OpenClaw | 源码与 Issue 追踪 |
| ClawHub 平台 | https://hub.OpenClaw.ai | 社区共享的人格模板 |
| Anthropic Prompt Engineering | https://docs.anthropic.com/claude/docs/system-prompts | System Prompt 设计参考 |

---

## 本章小结

- **人格体系**：SOUL.md（灵魂）+ IDENTITY.md（身份）+ AGENTS.md（行为）三层协同定义 Agent 人格。
- **SOUL.md**：定义核心价值观和底线原则，简洁有力，30-80 行为宜。
- **IDENTITY.md**：定义身份信息和能力范围，多 Agent 场景下实现差异化。
- **AGENTS.md**：定义场景化行为规范，是最常迭代的文件。
- **测试与优化**：人格设计需要持续迭代，每次改一个维度，测试后再改下一个。
- **架构原理**：人格文件按 SOUL → IDENTITY → AGENTS → MEMORY 顺序注入 Prompt，合理控制长度避免挤压对话空间。

> 下一章：[24-多模态与媒体处理](24-多模态与媒体处理.md)

---

<div align="center">

[← 上一章：Canvas 可视化交互](22-Canvas 可视化交互.md) · [📑 返回目录](README.md) · [下一章：多模态与媒体处理 →](24-多模态与媒体处理.md)

</div>
