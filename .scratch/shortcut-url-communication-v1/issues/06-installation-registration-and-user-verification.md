# 06 — 本机安装、LaunchServices 清理与手动验证说明

**What to build:** 本地安装流程保持 LaunchServices 注册干净，并给用户明确的快捷指令手动验证步骤，避免旧 Bundle ID 或旧动作块继续导致“无法通信”。

**Blocked by:** 04 — 收窄 AppIntent 动作并改走 URL Scheme.

**Status:** ready-for-agent

- [ ] 本地安装流程只注册 `/Applications` 中的正式白噪音 app。
- [ ] 本地安装流程不会让 build 目录或 DerivedData 中的临时 app 截获快捷指令动作。
- [ ] 安装后能验证系统只识别当前 Bundle ID 的正式 app。
- [ ] 用户说明中明确：删除旧快捷指令动作块后重新添加新的“白噪音”动作。
- [ ] 用户说明中包含最小手动验证路径：开始助眠、暂停或继续、停止、查询状态。
- [ ] DMG 或本地安装产物与当前 app 版本一致。
