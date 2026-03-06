# ❓ 常见问题（FAQ）

> 汇集 OpenClaw 使用过程中最常遇到的问题与解决方案

---

## 安装与部署

### Q: OpenClaw 支持哪些操作系统？

**A:** OpenClaw 支持 Linux（推荐 Ubuntu 22.04+）、macOS（Intel/Apple Silicon）以及 Windows（通过 WSL2）。生产环境推荐 Linux 部署。

### Q: 安装时提示权限不足怎么办？

**A:** 
```bash
# 方案 1：使用用户级安装
curl -fsSL https://openclaw.dev/install.sh | bash

# 方案 2：检查目录权限
ls -la ~/.openclaw/
chown -R $USER:$USER ~/.openclaw/
```

### Q: 部署后无法连接 Gateway？

**A:** 检查以下几点：
1. 确认 Gateway 端口（默认 3000）未被占用：`lsof -i :3000`
2. 检查防火墙规则：`ufw status`
3. 查看 Gateway 日志：`openclaw logs gateway`

---

## Skills 开发

### Q: 如何创建第一个 Skill？

**A:** 参考 [[03 Skills 插件体系与批量开发]]，最小 Skill 结构：
```
my-skill/
├── SKILL.md    # 技能说明文档
├── _meta.json  # 元数据配置
└── __init__.py # 入口逻辑（可选）
```

### Q: Skill 安装失败，如何排查？

**A:** 
1. 检查 `_meta.json` 格式：`cat _meta.json | python -m json.tool`
2. 检查依赖是否满足：查看 `dependencies` 字段
3. 手动安装测试：`openclaw skill install ./my-skill --verbose`

### Q: Skill 版本冲突如何解决？

**A:** 参考 [[04 Skills 安装与管理实践]]：
```bash
# 查看已安装版本
openclaw skill list --versions

# 强制更新到最新
openclaw skill update <skill-name> --force
```

---

## 自动化与集成

### Q: 定时任务不执行怎么办？

**A:** 参考 [[06 自动化命令与脚本集成]]：
```bash
# 查看任务状态
openclaw cron list

# 查看执行日志
openclaw cron logs <job-id>

# 手动触发测试
openclaw cron run <job-id> --now
```

### Q: 飞书通知发送失败？

**A:** 参考 [[07 飞书集成与消息自动化]]：
1. 确认凭证有效：`openclaw credential list`
2. 检查飞书应用权限（需要 `im:message:create`）
3. 测试连通性：`openclaw message send --channel feishu --target <chat_id> --message "test"`

### Q: 如何配置多个 Agent？

**A:** 参考 [[08 单 Gateway 多 Agent 配置]]，核心配置在 `openclaw.json`:
```json
{
  "agents": {
    "main": { "model": "claude-4-opus", "priority": 1 },
    "assistant": { "model": "claude-4-sonnet", "priority": 2 }
  }
}
```

---

## 故障排查

### Q: 日志在哪里？

**A:** 参考 [[09 故障排查与日志分析]]：
```bash
# 主日志
~/.openclaw/logs/

# 实时查看
openclaw logs -f

# 按级别过滤
openclaw logs --level error
```

### Q: Agent 无响应如何处理？

**A:** 
1. 检查进程状态：`openclaw status`
2. 查看 Agent 日志：`openclaw logs agent`
3. 重启服务：`openclaw restart`
4. 如仍无法解决，参考 [[09 故障排查与日志分析]] 的完整排查流程

---

> 💡 没找到答案？可以在 [GitHub Issues](https://github.com/zxk-git/openclaw-tutorial-auto/issues) 提问。
