# 03 — 实现快捷指令 URL 路由到 app 控制器

**What to build:** 白噪音 app 能识别快捷指令 v1 的 5 个 URL 命令，并由 app 控制器执行对应播放行为，而不依赖主窗口是否显示。

**Blocked by:** 02 — 注册 `whitenoise://` 并验证 app 元数据.

**Status:** ready-for-agent

- [ ] app 能解析 `whitenoise://shortcut/start-sleep` 并使用当前助眠音景开始播放。
- [ ] app 能解析 `whitenoise://shortcut/start-sleep-random` 并只从助眠池随机选择音景。
- [ ] app 能解析 `whitenoise://shortcut/toggle-pause`，播放中则暂停，暂停中则继续，未播放时不自动开始。
- [ ] app 能解析 `whitenoise://shortcut/stop` 并停止音频、取消倒计时。
- [ ] app 能解析 `whitenoise://shortcut/status` 并得到极简状态：正在播放、已暂停或未播放。
- [ ] 不支持的 URL 不会崩溃，也不会误触发播放。
