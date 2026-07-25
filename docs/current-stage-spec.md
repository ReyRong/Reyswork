# 白噪音 macOS App 现阶段规格书

## Problem Statement

用户需要一个低干扰、可长期使用的 macOS 白噪音应用，用于两个明确场景：助眠和专注。应用不应只是一个普通音频播放器，而应帮助用户快速进入某种状态：助眠时减少选择、柔和播放、可定时结束；专注时稳定播放、支持不限时、可暂停继续。

当前原型已经具备主界面、菜单栏、音景、计时、设置、登录项和快捷指令代码入口，但仍存在系统级落地风险：手工 SwiftPM 打包导致快捷指令无法被 macOS 快捷指令 App 发现，登录项和正式分发也会持续不稳定。用户需要把当前方向固化为阶段规格，并明确哪些是 v1 必须完成的产品地基，哪些应延后。

## Solution

将白噪音 App 定位为原生 macOS 状态工具，而不是媒体库播放器。v1 聚焦内置音频、助眠和专注两个场景、菜单栏快速操作、可靠播放控制、设置持久化、正式 macOS App target、快捷指令系统可发现、登录项稳定、可本机安装和后续分发。

用户打开应用后，主界面默认是简洁播放面板：左上角显示当前场景，中央显示当前状态、时钟或倒计时，用户只需要选择背景音、音量、时长，然后开始播放。设置入口收纳长期偏好和媒体库归属。菜单栏作为高频入口，应完成绝大多数轻量操作。

系统集成层面，项目应从手工 SwiftPM executable 打包迁移为正式 Xcode macOS App target，保留现有 Swift 源码和测试逻辑，同时让 Xcode 负责 AppIntents 元数据、Info.plist、Bundle ID、签名、资源、登录项、公证所需的构建链路。

## User Stories

1. As a sleep user, I want to start sleep noise quickly, so that I can reduce choices before bed.
2. As a sleep user, I want sleep mode to randomly choose from sounds I marked for sleep, so that I do not need to decide every night.
3. As a sleep user, I want a countdown in the center when I choose a timed session, so that I can know when playback will end.
4. As a sleep user, I want the session to fade out when it ends, so that I am not disturbed by an abrupt stop.
5. As a sleep user, I want sleep mode to default to a finite duration, so that the app does not play all night unless I choose that behavior later.
6. As a focus user, I want to start focus noise quickly, so that I can enter work, study, or reading mode without friction.
7. As a focus user, I want an unlimited duration option, so that background sound can continue through long work sessions.
8. As a focus user, I want the current clock centered when playback is unlimited, so that the app feels calm and does not imply an artificial deadline.
9. As a focus user, I want to choose which sounds belong to focus, so that the app matches my personal work environment.
10. As a user, I want to choose which sounds belong to sleep, so that I can keep stimulating sounds out of sleep mode.
11. As a user, I want each scene to always keep at least one soundscape, so that the app never enters an empty or unusable state.
12. As a user, I want to choose a background sound directly from the main view, so that the most important action stays visible.
13. As a user, I want to adjust volume from the main view, so that I can tune playback before starting.
14. As a user, I want to adjust volume from the menu bar, so that I do not need to open the main window during use.
15. As a user, I want to select duration from common presets, so that starting a session is fast.
16. As a user, I want to type a custom duration with the keyboard, so that I am not limited to presets.
17. As a user, I want the selected preset duration to be applied correctly, so that custom duration does not override my explicit choice.
18. As a user, I want a single clear start control, so that playback does not feel like operating a complicated media player.
19. As a user, I want pause and resume controls, so that I can temporarily stop sound without losing context.
20. As a user, I want stop to end both audio and countdown, so that playback and timer never drift apart.
21. As a user, I want paused timed sessions to keep showing the paused remaining time, so that the state is understandable.
22. As a user, I want switching scenes to clearly update the selected sidebar item, so that I know whether I am in sleep or focus.
23. As a user, I want the sidebar to collapse during playback, so that the playback surface becomes quieter and less distracting.
24. As a user, I want the main window to return to its initial centered size after leaving playback, so that the UI remains predictable.
25. As a user, I want the close button to hide the window and Dock icon while keeping the menu bar app alive, so that the app behaves like a background utility.
26. As a user, I want the menu bar icon to indicate playback state, so that I can glance at the app status.
27. As a user, I want the menu bar panel to show current scene, current soundscape, playback state, remaining time, volume, and core controls, so that I can manage playback without opening the main window.
28. As a user, I want menu bar hover and selected states to remain visually stable, so that the menu does not feel broken or crowded.
29. As a dark mode user, I want the app background and panels to feel visually unified, so that the interface does not look split into unrelated blocks.
30. As a dark mode user, I want the dark background to use the agreed near-black tone, so that the UI has a consistent product identity.
31. As a light mode user, I want the app to follow macOS visual language, so that it feels native.
32. As a user, I want settings to be narrower and focused, so that it feels like a preference sheet rather than a second app.
33. As a user, I want settings to contain long-term preferences, so that the main view stays focused on playback.
34. As a user, I want the media library assignment table in settings, so that I can control sound usage without crowding the main view.
35. As a user, I want login item status to be accurate, so that I know whether the app will start after login.
36. As a user, I want login startup to work from the installed app, so that I do not need to launch the app manually every day.
37. As a user, I want the app to start only when I open my Mac/login session, so that it does not behave like an always-running cloud service.
38. As a shortcuts user, I want to find the app in macOS Shortcuts, so that I can automate sleep and focus sessions.
39. As a shortcuts user, I want a “start sleep” action, so that automations can begin sleep noise.
40. As a shortcuts user, I want a “start focus” action, so that automations can begin focus noise.
41. As a shortcuts user, I want a “stop white noise” action, so that automations can reliably end playback.
42. As a shortcuts user, I want a “query status” action, so that automations can check what is currently playing.
43. As a shortcuts user, I want scene, soundscape, duration, and volume as parameters where appropriate, so that shortcuts remain expressive without becoming a cluttered list of remote-control buttons.
44. As a developer, I want AppIntents metadata to be generated by the official Xcode app build, so that macOS can index the shortcuts reliably.
45. As a developer, I want a stable Bundle ID, so that login items, shortcuts, signing, and future updates are tied to the same app identity.
46. As a developer, I want bundled audio resources to resolve correctly inside the installed app, so that playback does not crash or show false missing-file errors.
47. As a developer, I want audio licensing information recorded, so that distribution risk is understood before public sharing.
48. As a developer, I want tests around user-facing state transitions, so that UI and system integrations can be refactored safely.
49. As a future user, I want user-imported audio to be considered later, so that v1 can stay stable before expanding media-library complexity.
50. As a future shortcuts user, I want imported audio to appear as dynamic shortcut entities if import is added, so that automation remains useful beyond built-in sounds.

## Implementation Decisions

- Keep only two product scenes for v1: sleep and focus.
- Keep six built-in soundscapes for v1: ocean, fireplace, rain, summer night, cafe, and library.
- Treat soundscape-to-scene assignment as user-owned preference.
- Enforce that every scene always has at least one available soundscape.
- Sleep defaults to a finite timed session.
- Focus defaults to unlimited playback.
- Sleep start behavior should prefer random selection from the sleep pool.
- Focus start behavior should prefer the current selected focus soundscape.
- Main view should be the playback surface, not the media library.
- Media library assignment belongs in settings, not the main view.
- Settings should contain long-term preferences only: default scene, default volume, default durations, start behavior, media assignment, login item, and system integration status.
- Menu bar is a core surface, not secondary chrome. It should provide start, pause/resume, stop, volume, scene switching, soundscape switching, duration presets, settings, main window, and quit.
- Pause and stop must remain semantically distinct: pause preserves playback context and timer state; stop ends playback and cancels the timer.
- The close button hides the main window and Dock icon while leaving the menu bar app running.
- The app should preserve predictable main window sizing and centering after playback screen transitions.
- Dark mode should use a unified near-black background and avoid excessive divider/table styling.
- Built-in audio files must be bundled into the installed app resources and resolved from the installed bundle layout.
- Audio quality work is part of v1 readiness: volume normalization, loop smoothness, fade behavior, file size, and licensing provenance.
- The current hand-built SwiftPM executable package is not sufficient as the long-term app container.
- The project should migrate to a formal Xcode macOS App target while preserving the existing domain logic and tests.
- Xcode should own Info.plist generation or inclusion, AppIntents metadata extraction, app resources, signing, and installed app packaging.
- The Bundle ID should be changed from a temporary local identifier to a stable reverse-DNS identifier before relying on shortcuts, login items, signing, or updates.
- Current AppIntent actions should be simplified over time toward scene-level actions with parameters, rather than a large number of button-like actions.
- Future user-imported audio is out of v1, but the model should not paint the project into a corner where only static enum soundscapes can ever exist.

## Testing Decisions

- The highest preferred testing seam is the app controller behavior: scene selection, soundscape selection, duration selection, playback state commands, timer coordination, settings persistence, and shortcut command handling.
- Existing pure domain seams should remain covered: timer behavior, soundscape selection, scene assignment rules, playback presentation, menu bar presentation, resource resolution, and system status messaging.
- UI tests should assert user-visible state and presentation models where possible rather than internal SwiftUI layout details.
- Shortcut tests should validate command behavior and available user actions, but system discovery in the macOS Shortcuts app requires an installed Xcode-built app and should be covered by manual/system verification.
- Audio resource tests should continue verifying that built-in soundscapes resolve in both build and installed-bundle layouts.
- Login item tests should focus on user-facing status mapping and safe failure behavior; full enablement requires an installed, properly bundled app.
- Good tests should fail when the user-visible contract breaks, not when implementation details are renamed.
- Prior test patterns already exist for timer pause/resume, focus unlimited duration, scene assignment invariants, menu bar presentation symbols, playback session presentation, settings persistence, resource lookup, shortcut command clamping, and window close behavior.

## Out of Scope

- User-imported audio files are out of scope for v1.
- Cloud sync, accounts, remote media libraries, playlists, and recommendations are out of scope.
- Private APIs for controlling macOS Focus mode are out of scope.
- App Store submission is out of scope for the immediate stage, though signing and notarization readiness should be considered.
- Advanced audio mixing, multiple simultaneous layers, equalizer controls, and soundscape composition are out of scope for v1.
- iOS, iPadOS, watchOS, and cross-device handoff are out of scope.
- Analytics, telemetry, subscriptions, and paid features are out of scope.
- A marketing landing page is out of scope; the app should open directly into the usable experience.

## Further Notes

- The app should be treated as a calm macOS utility whose product promise is state transition: sleep or focus, quickly and quietly.
- The most important near-term technical correction is the migration from hand-built SwiftPM app packaging to a formal Xcode macOS app target.
- The currently observed shortcut discovery failure is a product signal, not just a bug: system integrations require the project to use the correct native app packaging path.
- After Xcode target migration, the next verification should be: installed app launches, menu bar appears, audio resources play, login item status is accurate, shortcuts appear in macOS Shortcuts, and close-to-menu-bar behavior remains intact.
- The issue tracker and triage label vocabulary were not available in this workspace context, so this spec is stored as a project document rather than being published to an issue tracker.

# 快捷指令通信 v1 规格

## Problem Statement

用户已经可以在 macOS 快捷指令中看到“白噪音”相关动作，但运行时出现“快捷指令与白噪音无法通信”。这说明问题不只是动作是否可发现，而是快捷指令运行时无法可靠地把命令交给正在运行或将要启动的 app。

当前实现让 AppIntent 直接调用 app 内部的进程内请求中心。这种方式依赖 AppIntent 和 SwiftUI app controller 处在同一个已初始化进程里。一旦快捷指令由系统后台 runner 执行，或 app 尚未完成初始化，动作就可能存在但无法真正触发白噪音播放、暂停、停止或状态查询。

用户需要一个 v1 可落地的快捷指令通信方案：动作数量保持克制，执行路径稳定，app 不主动弹出主窗口，且可以在 app 未启动时唤起 app 并执行命令。

## Solution

快捷指令 v1 改为 URL Scheme 通信。AppIntent 不再把命令直接发给进程内 singleton，而是打开一个 `whitenoise://` URL。白噪音 app 在启动或运行中接收 URL，并由 app 内部 controller 执行对应命令。

从用户角度看，快捷指令仍然是“白噪音”的原生动作；从系统角度看，动作执行路径变为：

`快捷指令 AppIntent -> 打开 whitenoise:// URL -> 白噪音 app 接收 URL -> 执行播放控制`

快捷指令执行时只唤起 app 或菜单栏，不主动显示主窗口。成功或失败通过快捷指令返回文本表达。v1 不暴露时长、音景、音量等参数，只提供固定动作，减少自动化入口复杂度。

## User Stories

1. As a shortcuts user, I want Shortcuts actions to communicate reliably with White Noise, so that my automations do not fail after the app is installed.
2. As a sleep user, I want a “start sleep” shortcut action, so that I can begin my current sleep soundscape from Shortcuts.
3. As a sleep user, I want a “random sleep soundscape” shortcut action, so that the app can reduce my choices before bed.
4. As a sleep user, I want random sleep soundscape selection to use only soundscapes I marked for sleep, so that stimulating focus sounds are not selected at night.
5. As a user, I want a single “pause or resume” shortcut action, so that I do not need to decide which control belongs in an automation.
6. As a user, I want the pause-or-resume shortcut to pause when white noise is playing, so that I can temporarily stop sound.
7. As a user, I want the pause-or-resume shortcut to resume when white noise is paused, so that I can continue without rebuilding the session.
8. As a user, I want the pause-or-resume shortcut to avoid starting playback when nothing is active, so that the action does not unexpectedly create sound.
9. As a user, I want a “stop white noise” shortcut action, so that I can end audio and countdown from automation.
10. As a user, I want a “query status” shortcut action, so that I can know whether the app is playing, paused, or idle.
11. As a user, I want the status shortcut to return only a simple playback state, so that it is readable in notifications and automations.
12. As a user, I want shortcut actions to work even when the app is not already open, so that automation feels dependable.
13. As a user, I want shortcut actions to avoid opening the main window, so that sleep and focus flows remain low-interruption.
14. As a user, I want shortcut actions to keep the menu-bar utility feeling, so that app automation does not feel like launching a full workspace.
15. As a user, I want shortcut actions to use the installed app identity, so that old development builds do not intercept commands.
16. As a user, I want old shortcut actions created before the Bundle ID change to be replaceable with clean new actions, so that stale references do not keep failing.
17. As a developer, I want shortcut commands to travel through an explicit URL command boundary, so that AppIntent runtime behavior is easier to debug.
18. As a developer, I want URL commands to be parsed into the same controller-level command model used by the app, so that behavior remains consistent.
19. As a developer, I want shortcut command tests at the app command seam, so that the tests verify user-visible behavior rather than SwiftUI layout details.
20. As a developer, I want URL route tests for all supported shortcut URLs, so that unsupported or misspelled URLs fail predictably.

## Implementation Decisions

- v1 shortcut communication uses a custom URL Scheme rather than direct in-process singleton dispatch.
- The app registers the `whitenoise` URL Scheme in its app metadata.
- The SwiftUI app scene receives shortcut URLs and forwards them to the app controller.
- The controller executes shortcut commands without requiring the main window to be visible.
- Shortcut execution should not actively present the main window.
- AppIntent actions open the appropriate URL and return a concise dialog result.
- v1 exposes five shortcut actions: start sleep, random sleep soundscape, pause or resume, stop, and query status.
- v1 removes the start focus shortcut action from the immediate shortcut surface.
- v1 combines pause and resume into a single toggle-style action.
- v1 query status returns only one of three user-facing states: playing, paused, or idle.
- Start sleep uses the current selected sleep soundscape.
- Random sleep soundscape selects only from soundscapes assigned to the sleep scene.
- Stop ends playback and cancels any running countdown.
- Pause or resume does not start playback when the app is idle.
- v1 does not expose URL parameters for duration, soundscape, scene, or volume.
- The planned URL routes are:
  - `whitenoise://shortcut/start-sleep`
  - `whitenoise://shortcut/start-sleep-random`
  - `whitenoise://shortcut/toggle-pause`
  - `whitenoise://shortcut/stop`
  - `whitenoise://shortcut/status`
- The local install process must keep LaunchServices registration clean so Shortcuts does not bind to old Bundle IDs or temporary build products.
- Existing shortcuts created before the Bundle ID migration may need to be rebuilt by deleting old shortcut action blocks and adding new ones.

## Testing Decisions

- The highest test seam is the controller-level shortcut command behavior, because it represents what the user expects regardless of whether the command came from UI, menu bar, AppIntent, or URL.
- Add or keep tests proving start sleep uses the current sleep soundscape.
- Add or keep tests proving random sleep selects only from the sleep soundscape pool.
- Add tests proving pause-or-resume pauses active playback, resumes paused playback, and does not start idle playback.
- Add tests proving stop cancels playback and timer state.
- Add tests proving query status returns only playing, paused, or idle.
- Add URL parsing tests for every v1 shortcut URL.
- Add app metadata tests proving the `whitenoise` URL Scheme is registered.
- Keep LaunchServices install-script tests so local development does not reintroduce duplicate app registrations.
- System discovery in the macOS Shortcuts app remains a manual verification step because it depends on installed app registration and system indexing.

## Out of Scope

- Start focus as a shortcut action is out of scope for shortcut v1.
- Shortcut parameters for duration, soundscape, scene, volume, or fade behavior are out of scope for shortcut v1.
- Dynamic shortcut entities for user-imported audio are out of scope.
- A background XPC service, App Group command queue, or full automation service architecture is out of scope for shortcut v1.
- Private APIs for macOS Focus mode remain out of scope.
- Automatically repairing user-created shortcuts that still reference old Bundle IDs is out of scope; users may need to replace old action blocks.

## Further Notes

- This spec deliberately keeps shortcut v1 smaller than the app's full product model. The app can remain both sleep and focus oriented while the first reliable shortcut surface focuses on sleep automation.
- URL Scheme communication is chosen because it is explicit, testable, and suitable for a local macOS utility at this stage.
- If shortcut reliability still fails after URL Scheme migration, the next architectural question should be whether a signed helper, App Group, or XPC boundary is needed.
- The issue tracker and triage label vocabulary were not available in this workspace context, so this shortcut communication spec is stored in the project document rather than being published to an issue tracker.
