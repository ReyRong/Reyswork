# 白噪音

一个原生 macOS 白噪音应用，用于两个低干扰场景：助眠和专注。应用常驻菜单栏，同时提供主窗口控制音景、音量、时长和播放状态。

## 当前状态

- 原生 macOS SwiftUI 应用
- 支持菜单栏常驻和主窗口播放界面
- 支持助眠、专注两个场景
- 支持内置音景：沙滩海声、壁炉柴火、淅淅雨声、虫鸣夏夜、咖啡厅环境、图书馆氛围
- 支持音景归属设置：用户可决定每个音景用于助眠、专注或两者
- 支持定时播放、不限时专注、暂停/继续、停止、音量调节
- 支持关闭主窗口后保持菜单栏运行
- 支持 URL Scheme 快捷指令入口

## 快捷指令

当前本机版没有 Apple 开发者签名，因此暂不启用原生 AppIntent 动作。请在 macOS 快捷指令中使用系统动作“打开 URL”，填入以下地址：

```text
whitenoise://shortcut/start-sleep
whitenoise://shortcut/start-sleep-random
whitenoise://shortcut/toggle-pause
whitenoise://shortcut/stop
```

说明：

- `start-sleep`：使用当前助眠音景开始播放
- `start-sleep-random`：从助眠音景池随机播放
- `toggle-pause`：播放时暂停，暂停时继续；未播放时不会自动开始
- `stop`：停止音频并取消倒计时

`whitenoise://shortcut/status` 也存在，但 URL 方式不适合向快捷指令返回文本状态；原生状态查询会等正式签名后的 AppIntent 版本再恢复。

## 本地开发

要求：

- macOS 13 或更高
- Xcode
- Swift 5.9 或更高

运行测试：

```bash
swift test
```

构建本地 `.app`：

```bash
scripts/build-app.sh
```

安装到本机 `/Applications` 并打开：

```bash
scripts/install-local.sh
```

生成 DMG：

```bash
scripts/build-dmg.sh
```

## 音频资源

内置音频文件位于：

```text
Sources/SleepAidApp/Resources/Audio
```

支持文件名：

- `ocean.m4a`
- `fireplace.m4a`
- `rain.m4a`
- `summer-night.m4a`
- `cafe.m4a`
- `library.m4a`

公开分发前需要继续整理每个音频文件的来源、授权、循环质量和音量一致性。

## 项目结构

```text
Sources/SleepAidApp/App        App 入口和控制器
Sources/SleepAidApp/UI         SwiftUI 界面
Sources/SleepAidApp/Core       场景、音景、计时、设置模型
Sources/SleepAidApp/Audio      音频播放和资源解析
Sources/SleepAidApp/System     登录项、Focus/快捷指令相关边界
Tests/SleepAidAppTests         单元测试
scripts                        构建、安装、打包脚本
docs                           当前阶段规格
```

## 后续计划

- 用正式 Apple 签名恢复原生 AppIntent 快捷指令
- 完善登录项在正式签名包中的表现
- 补充音频授权记录
- 继续打磨菜单栏控制体验
- 评估后续是否支持用户导入自定义白噪音
