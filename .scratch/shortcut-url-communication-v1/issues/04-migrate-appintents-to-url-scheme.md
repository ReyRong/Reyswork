# 04 — 收窄 AppIntent 动作并改走 URL Scheme

**What to build:** macOS 快捷指令中的“白噪音”动作使用 URL Scheme 与 app 通信，且 v1 只暴露用户确认的 5 个动作。

**Blocked by:** 03 — 实现快捷指令 URL 路由到 app 控制器.

**Status:** ready-for-agent

- [ ] 快捷指令 v1 只暴露：开始助眠、助眠白噪音随机、暂停或继续、停止、查询状态。
- [ ] 移除开始专注、独立暂停、独立继续、设置时长、切换音景这些 v1 不需要的快捷指令入口。
- [ ] AppIntent 动作不再直接依赖进程内请求中心来执行播放命令。
- [ ] AppIntent 动作打开对应 `whitenoise://shortcut/...` URL。
- [ ] AppIntent 返回简洁、可读的执行结果文本。
