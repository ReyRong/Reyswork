# 02 — 注册 `whitenoise://` 并验证 app 元数据

**What to build:** 安装后的白噪音 app 可以被系统通过 `whitenoise://` 唤起，并且安装包元数据能证明 URL Scheme 已注册。

**Blocked by:** 01 — 清理快捷指令 v1 规格与工作区状态.

**Status:** ready-for-agent

- [ ] app 元数据注册 `whitenoise` URL Scheme。
- [ ] 自动测试能验证项目元数据包含 `whitenoise` URL Scheme。
- [ ] Xcode 构建后的安装包仍包含正确的 Bundle ID、显示名、版本号和 AppIntents metadata。
- [ ] 本机安装后，`open whitenoise://shortcut/status` 可以唤起白噪音 app。
