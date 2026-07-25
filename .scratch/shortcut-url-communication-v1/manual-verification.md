# 快捷指令通信 v1 手动验证

## 安装后系统检查

- `/Applications/SleepAidApp.app` 的 Bundle ID 应为 `com.rey.whitenoise`。
- 安装包应声明 `whitenoise:` URL Scheme。
- LaunchServices 中不应残留 `app.white-noise.local` 或 build 目录下的临时白噪音 app 注册。
- 安装包资源中应包含 `Metadata.appintents`。

## URL Scheme 验证

运行以下命令后，`WhiteNoise.ShortcutStatus.v1` 应出现对应状态：

- `open 'whitenoise://shortcut/start-sleep'` -> `正在播放`
- `open 'whitenoise://shortcut/start-sleep-random'` -> `正在播放`
- `open 'whitenoise://shortcut/toggle-pause'` -> `已暂停` 或 `正在播放`
- `open 'whitenoise://shortcut/stop'` -> `未播放`

## app 未启动验证

1. 退出白噪音 app。
2. 运行 `open 'whitenoise://shortcut/start-sleep'`。
3. 确认白噪音 app 被启动。
4. 确认状态变为 `正在播放`。

## 快捷指令 App 验证

如果之前创建过旧的白噪音快捷指令动作，需要先删除旧动作块，再重新从动作库添加新的“白噪音”动作。

最小验证路径：

1. 添加并运行“开始助眠白噪音”，预期开始播放。
2. 添加并运行“暂停或继续白噪音”，预期播放中暂停、暂停中继续。
3. 添加并运行“停止白噪音”，预期停止播放。
4. 添加并运行“查询白噪音状态”，预期只返回 `正在播放`、`已暂停` 或 `未播放`。
