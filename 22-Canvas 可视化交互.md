<div align="center">

[← 第 21 章](21-多飞书多 Agent 实战配置.md) · [📑 目录](README.md) · [📋 大纲](OUTLINE.md) · [第 23 章 →](23-Agent 人格与行为设计.md)

</div>

# 第 22 章：Canvas 可视化交互

![difficulty](https://img.shields.io/badge/难度-⭐⭐_中级-yellow) ![time](https://img.shields.io/badge/阅读时间-22_分钟-blue) ![chapter](https://img.shields.io/badge/章节-22%2F25-purple)

> **难度**: ⭐⭐ 中级 | **预计阅读**: 22 分钟 | **前置章节**: [第 1 章](01-基础介绍与安装.md)、[第 17 章](17-浏览器自动化与网页交互.md)

> Canvas 是 OpenClaw 提供的可视化交互界面，允许用户通过浏览器与 Agent 进行图形化的实时协作。本章将介绍 Canvas 的架构、配置方法、交互模式和自定义扩展技巧。

## 📑 本章目录

- [22.1 Canvas 概述](#221-canvas-概述)
- [22.2 启动与配置](#222-启动与配置)
- [22.3 Canvas 交互模式](#223-canvas-交互模式)
- [22.4 自定义 Canvas 布局](#224-自定义-canvas-布局)
- [22.5 Canvas 与 Agent 协作](#225-canvas-与-agent-协作)
- [进阶：Canvas 渲染架构原理](#进阶 canvas-渲染架构原理)
- [注意事项与常见错误](#注意事项与常见错误)
- [实操练习](#实操练习)
- [常见问题 (FAQ)](#常见问题-faq)
- [参考来源](#参考来源)
- [本章小结](#本章小结)

---

## 22.1 Canvas 概述

Canvas 是 OpenClaw 内置的 Web 可视化界面，基于浏览器技术栈运行。它为 Agent 提供了一个富交互的工作台面，支持实时内容预览、Markdown 编辑、数据可视化和任务状态监控。

### Canvas 的核心能力

| 能力 | 说明 | 典型用途 |
|------|------|----------|
| 实时预览 | Agent 生成的内容即时渲染 | 文档编辑、报告预览 |
| 交互式编辑 | 支持拖拽、点选等图形化操作 | 工作流编排、布局调整 |
| 数据可视化 | 图表、表格、流程图渲染 | 数据分析结果展示 |
| 状态监控 | Pipeline 和任务执行状态实时显示 | 自动化流程监控 |
| 多媒体展示 | 图片、视频、音频内联展示 | 媒体处理结果预览 |

### Canvas 与传统 CLI 对比

| 维度 | CLI 交互 | Canvas 交互 |
|------|----------|-------------|
| 输入方式 | 纯文本命令 | 文本 + 图形操作 |
| 输出格式 | 文本流 | 富媒体渲染 |
| 实时性 | 输出完成后显示 | 流式实时渲染 |
| 协作性 | 单人操作 | 多窗口并行查看 |
| 学习门槛 | 需记忆命令 | 可视化操作直觉性强 |

> Canvas 不是取代 CLI 的工具，而是针对特定场景（如内容编辑、数据可视化）提供更好的用户体验。两种方式可以结合使用。

---

## 22.2 启动与配置

### 启动 Canvas 服务

Canvas 作为 Gateway 的一部分运行，默认通过浏览器访问：

```bash
# 确保 Gateway 正在运行
openclaw gateway status

# 查看 Canvas 访问地址
openclaw config get canvas.url

# 如果 Gateway 未启动，先启动它
openclaw gateway start

# Canvas 默认监听地址
echo "Canvas URL: http://localhost:18789/canvas/"
```

启动后，在浏览器中打开 `http://localhost:18789/canvas/` 即可访问 Canvas 界面。

### 配置 Canvas 参数

Canvas 的行为可以通过配置文件定制：

```yaml
# ~/.openclaw/openclaw.json 中的 canvas 配置段
{
  "canvas": {
    "enabled": true,
    "theme": "auto",
    "defaultLayout": "split",
    "maxRenderSize": 10485760,
    "autoRefresh": true,
    "refreshInterval": 2000
  }
}
```

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `enabled` | `true` | 是否启用 Canvas 功能 |
| `theme` | `"auto"` | 主题模式：`auto` / `light` / `dark` |
| `defaultLayout` | `"split"` | 默认布局：`split`（分栏）/ `full`（全屏）/ `panel`（面板）|
| `maxRenderSize` | `10MB` | 最大渲染文件大小（字节）|
| `autoRefresh` | `true` | 是否自动刷新内容变更 |
| `refreshInterval` | `2000` | 自动刷新间隔（毫秒）|

> 在低配设备上，建议关闭 `autoRefresh` 或增大 `refreshInterval` 以减少资源占用。

---

## 22.3 Canvas 交互模式

Canvas 支持多种交互模式，适用于不同的工作场景：

### 编辑模式

编辑模式提供完整的 Markdown 编辑体验，支持实时预览和语法高亮：

```bash
# 通过 CLI 在 Canvas 中打开文件进行编辑
openclaw canvas open ~/.openclaw/workspace/SOUL.md

# 打开单一文件并进入全屏编辑模式
openclaw canvas open --layout full README.md

# 同时打开多个文件进行对比编辑
openclaw canvas open --layout split file1.md file2.md
```

编辑模式的快捷键：

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+S` | 保存当前文件 |
| `Ctrl+P` | 切换预览模式 |
| `Ctrl+Shift+V` | 纯文本粘贴 |
| `Ctrl+/` | 切换行注释 |
| `Ctrl+B` | 加粗选中文本 |

### 监控模式

监控模式用于实时查看 Pipeline 或 Cron 任务的执行状态：

```bash
# 在 Canvas 中监控当前 Pipeline 执行
openclaw canvas monitor --pipeline tutorial-auto

# 监控所有 Cron 任务状态
openclaw canvas monitor --cron

# 监控 Gateway 资源使用
openclaw canvas monitor --resources
```

### 仪表板模式

仪表板模式提供系统级的概览信息：

```json
{
  "canvas": {
    "dashboard": {
      "widgets": [
        {"type": "agentStatus", "position": "top-left"},
        {"type": "cronHistory", "position": "top-right"},
        {"type": "memoryStats", "position": "bottom-left"},
        {"type": "taskQueue", "position": "bottom-right"}
      ]
    }
  }
}
```

---

## 22.4 自定义 Canvas 布局

Canvas 支持通过 HTML 和 CSS 自定义布局和样式。布局文件位于 `~/.openclaw/canvas/` 目录下。

### 布局文件结构

```text
~/.openclaw/canvas/
├── index.html         # 主入口页面
├── styles/            # 自定义样式
│   ├── theme-dark.css
│   └── theme-light.css
├── widgets/           # 自定义小部件
│   ├── status.html
│   └── chart.html
└── assets/            # 静态资源
    ├── logo.svg
    └── fonts/
```

### 创建自定义小部件

你可以编写 HTML 小部件来扩展 Canvas 的功能：

```html
<!-- widgets/memory-overview.html -->
<div class="widget memory-overview">
  <h3>📊 记忆系统概览</h3>
  <div id="memory-stats">
    <div class="stat-item">
      <span class="label">记忆文件数</span>
      <span class="value" data-bind="memory.fileCount">--</span>
    </div>
    <div class="stat-item">
      <span class="label">总大小</span>
      <span class="value" data-bind="memory.totalSize">--</span>
    </div>
    <div class="stat-item">
      <span class="label">最近更新</span>
      <span class="value" data-bind="memory.lastUpdate">--</span>
    </div>
  </div>
</div>
```

### 注册自定义小部件

```bash
# 将自定义小部件注册到 Canvas
openclaw canvas widget add memory-overview \
  --file widgets/memory-overview.html \
  --position bottom-left

# 查看已注册的小部件
openclaw canvas widget list

# 移除小部件
openclaw canvas widget remove memory-overview
```

---

## 22.5 Canvas 与 Agent 协作

Canvas 最大的价值在于作为人与 Agent 的可视化协作界面。

### Agent 输出渲染

Agent 的输出可以直接渲染到 Canvas 中，支持多种格式：

| 输出类型 | 渲染方式 | 示例 |
|---------|---------|------|
| Markdown | 富文本渲染 | 文档、报告、笔记 |
| Mermaid | 流程图/时序图 | 架构图、决策树 |
| JSON/YAML | 语法高亮 + 折叠 | 配置文件、API 响应 |
| CSV/表格 | 可排序表格 | 数据分析结果 |
| HTML | 内嵌预览 | 网页模板、邮件模板 |

### 在 Agent 对话中使用 Canvas

```bash
# 告诉 Agent 将输出发送到 Canvas
openclaw chat --canvas "请分析 cron/runs 目录下最近 10 次任务执行结果，生成趋势图"

# Agent 可以动态更新 Canvas 内容
# 对话中输入：
# "请在 Canvas 中创建一个记忆系统架构图（Mermaid 格式）"
```

Agent 会自动检测 Canvas 是否可用，并选择最合适的输出格式。例如，当 Canvas 打开时，Mermaid 代码会直接渲染为图形，而非显示原始代码。

### 实时协作流程

Canvas 支持"Agent 编辑 + 用户审查"的协作模式：

1. **Agent 生成内容** — 在 Canvas 编辑区域实时写入
2. **用户实时查看** — 在预览区域同步查看渲染结果
3. **用户标注反馈** — 通过高亮、批注、评论等方式反馈
4. **Agent 修改优化** — 根据反馈即时调整内容

> 这种协作模式特别适合文档编写、代码审查和数据报告等需要人机交互的场景。

---

## 进阶：Canvas 渲染架构原理

Canvas 的渲染系统基于浏览器原生能力构建，理解其架构有助于性能优化和自定义开发。

### 渲染管线

| 阶段 | 技术 | 职责 |
|------|------|------|
| 数据获取 | WebSocket | 从 Gateway 实时接收 Agent 输出 |
| 内容解析 | Markdown-it | 将 Markdown 解析为 AST |
| 插件扩展 | Mermaid/KaTeX/Highlight.js | 处理特殊内容块 |
| DOM 渲染 | Virtual DOM | 增量更新页面 |
| 样式应用 | CSS Variables | 主题切换和自定义样式 |

### WebSocket 通信协议

Canvas 与 Gateway 之间通过 WebSocket 保持长连接，消息格式如下：

```json
{
  "type": "canvas.update",
  "payload": {
    "target": "main-editor",
    "action": "append",
    "content": "## 新增标题\n\n这是 Agent 实时生成的内容...",
    "format": "markdown"
  },
  "timestamp": "2026-03-06T10:30:00Z"
}
```

消息类型包括：`canvas.update`（内容更新）、`canvas.clear`（清空画布）、`canvas.layout`（布局变更）、`canvas.widget`（小部件操作）。

---

## 注意事项与常见错误

使用 Canvas 时以下问题容易被忽视：

| 常见错误 | 后果 | 正确做法 |
|---------|------|----------|
| 大文件直接在 Canvas 编辑 | 浏览器卡顿甚至崩溃 | 检查 `maxRenderSize` 限制，大文件用 CLI 处理 |
| 未关闭旧的 Canvas 标签页 | WebSocket 连接累积，占用 Gateway 资源 | 不用时关闭标签页，或用 `openclaw canvas sessions` 检查 |
| 自定义小部件不做错误处理 | 一个小部件报错导致整个 Canvas 白屏 | 每个小部件用 try-catch 包裹逻辑 |

> **最佳实践**：在生产环境中，建议通过 Nginx 反向代理 Canvas，配置 HTTPS 和访问控制，避免直接暴露 Gateway 端口。

---

## 实操练习

### 练习 1：启动并访问 Canvas

**目标**：验证 Canvas 服务正常运行。

```bash
# Step 1: 检查 Gateway 状态
openclaw gateway status

# Step 2: 确认 Canvas 已启用
openclaw config get canvas.enabled

# Step 3: 获取 Canvas URL
CANVAS_URL=$(openclaw config get canvas.url 2>/dev/null || echo "http://localhost:18789/canvas/")
echo "Canvas URL: $CANVAS_URL"

# Step 4: 检查 Canvas 页面是否可访问
curl -s -o /dev/null -w "%{http_code}" "$CANVAS_URL" && echo " ✅ Canvas 可访问" || echo " ❌ Canvas 不可访问"
```

### 练习 2：自定义 Canvas 主题

**目标**：创建一个自定义的深色主题。

```bash
# Step 1: 创建自定义样式目录
mkdir -p ~/.openclaw/canvas/styles/

# Step 2: 编写自定义主题
cat > ~/.openclaw/canvas/styles/my-theme.css << 'EOF'
:root {
  --bg-primary: #1a1a2e;
  --bg-secondary: #16213e;
  --text-primary: #e0e0e0;
  --text-secondary: #a0a0a0;
  --accent: #0f3460;
  --highlight: #e94560;
}

.canvas-editor {
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  line-height: 1.6;
}
EOF

# Step 3: 应用自定义主题
openclaw config set canvas.theme my-theme
echo "✅ 自定义主题已应用，刷新浏览器查看效果"
```

### 练习 3：创建监控仪表板

**目标**：配置一个系统状态监控仪表板。

```bash
# Step 1: 创建仪表板配置
cat > ~/.openclaw/canvas/dashboard.json << 'EOF'
{
  "layout": "grid",
  "columns": 2,
  "widgets": [
    {
      "id": "agent-status",
      "type": "agentStatus",
      "title": "Agent 状态",
      "refreshInterval": 5000
    },
    {
      "id": "cron-history",
      "type": "cronHistory",
      "title": "Cron 执行历史",
      "maxItems": 20
    },
    {
      "id": "memory-stats",
      "type": "memoryStats",
      "title": "记忆系统",
      "showChart": true
    }
  ]
}
EOF

# Step 2: 验证配置
python3 -m json.tool ~/.openclaw/canvas/dashboard.json > /dev/null \
  && echo "✅ 仪表板配置有效" \
  || echo "❌ 配置格式错误"

# Step 3: 重启 Canvas 加载新配置
openclaw gateway reload
echo "仪表板已配置，访问 Canvas 的 /dashboard 路径查看"
```

---

## 常见问题 (FAQ)

### Q1：Canvas 打开后白屏怎么办？

**A**：检查以下几点：
1. 确认 Gateway 正在运行：`openclaw gateway status`
2. 检查浏览器控制台（F12）是否有 JavaScript 错误
3. 尝试清除浏览器缓存后刷新
4. 确认 `canvas.enabled` 为 `true`：`openclaw config get canvas.enabled`

### Q2：Canvas 编辑大文件时很卡？

**A**：Canvas 的 `maxRenderSize` 默认为 10MB。对于超大文件，建议：
- 降低 `refreshInterval` 减少渲染频率
- 使用 `--layout full` 模式减少 DOM 元素
- 大于 10MB 的文件建议使用 CLI 编辑器处理

### Q3：如何在 Canvas 中显示 Mermaid 图表？

**A**：Canvas 内置了 Mermaid 渲染支持。在 Markdown 中使用 ```mermaid` 代码块即可自动渲染为图形。确保浏览器支持 SVG 渲染。

### Q4：Canvas 可以远程访问吗？

**A**：默认监听 localhost。需要远程访问时，通过 Nginx 反向代理配置，并添加认证机制，避免直接暴露 Gateway 端口到公网。

---

## 参考来源

| 来源 | 链接 | 说明 |
|------|------|------|
| OpenClaw 官方文档 | https://docs.OpenClaw.ai | Canvas 功能文档 |
| OpenClaw GitHub | https://github.com/OpenClaw/OpenClaw | 源码与 Issue 追踪 |
| Mermaid 官方文档 | https://mermaid.js.org | 图表语法参考 |
| Markdown-it 文档 | https://markdown-it.github.io | Markdown 解析器 |

---

## 本章小结

- **Canvas 概述**：了解了 Canvas 作为 OpenClaw 可视化交互界面的定位和核心能力。
- **启动与配置**：掌握了通过 CLI 启动 Canvas 服务和自定义配置参数的方法。
- **交互模式**：学会了编辑模式、监控模式和仪表板模式三种使用方式。
- **自定义布局**：了解了布局文件结构和自定义小部件的开发方法。
- **Agent 协作**：掌握了 Canvas 与 Agent 实时协作的工作流程。
- Canvas 适用于内容编辑、数据可视化和任务监控等场景，与 CLI 互补使用效果最佳。

> 下一章：[23-Agent 人格与行为设计](23-Agent 人格与行为设计.md)

---

<div align="center">

[← 上一章：多飞书多 Agent 实战配置](21-多飞书多 Agent 实战配置.md) · [📑 返回目录](README.md) · [下一章：Agent 人格与行为设计 →](23-Agent 人格与行为设计.md)

</div>
