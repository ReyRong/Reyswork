# 自动化静默启动状态

更新：2026-11-18。状态：用户验收通过，测试环境已清理，本阶段随本次本地提交归档；未推送、正式 App 未替换。

## 当前关闭结论

2026-11-18 用户明确回复“通过”，本阶段验收关闭。

- 已正常退出测试 App，并确认测试进程数0；清理用户Applications中的测试 App、临时/旧版副本、源码快照、DerivedData及类型检查缓存。
- 已注销专用测试地址；实际系统查询返回 NO_HANDLER。正式 whitenoise URL 未改动。
- 最新测试偏好导出备份后清除独立测试域及空偏好文件；正式偏好已在清理前后分别备份并比较，一致，没有还原旧快照。
- 已核实本机50548端口是本轮Python服务，正常中断并确认停止；未强杀应用或操作其他服务。
- 构建日志、运行JSONL、验证汇总、诊断源码证据和偏好备份保留在 `/private/tmp/sleepaid-silent-test-20261117/`，不纳入Git。编译产物与临时App已清除。
- 本阶段代码与文档进行本地提交，不推送。正式 App 仍为现有安装版，未替换；要让正式自动化使用新行为，需要用户另行明确要求安装正式版。
- 后文的失败、待批准和待验收均是过程记录，以本节最终结论为准；未实测项保留，不因用户验收而改写为全自动测试通过。

## 用户确认的行为

- 自动化通过既有 whitenoise URL 启动时，只执行命令，不主动打开主窗口或 Dock。
- 从菜单栏手动打开主窗口/设置时显示 Dock。后台命令不强制关闭用户已经手动打开的窗口。
- 正常手动启动 App 仍尊重已有“打开主界面”偏好，设置说明调整为“手动启动时打开主界面”。
- 主窗口和设置均可隐藏关闭，播放不中断；还有其他可见普通窗口时保持 Dock，最后一个隐藏后再隐藏 Dock。

## 源码改动

- Info.plist 的 LSUIElement=true，从启动阶段即作为菜单栏后台应用。
- MenuBarExtra 先创建；macOS 15+ 使用公开场景接口 suppressed/disabled 禁止默认呈现及系统恢复。macOS 13/14 保留旧场景分支并返回“不打开无标题窗口”，该旧系统分支尚未实机验证。
- 控制器在 App 场景初始化期间接入，不再等主窗口 onAppear。重复配置按控制器身份幂等处理；排队命令在下一次主执行任务中转发，避免在场景生成过程中改播放状态。
- AppDelegate 根据 launchIsDefaultUserInfoKey 区分默认启动与资源/URL 启动。窗口打开动作就绪前的手动请求可排队，自动化命令可取消尚未呈现的默认启动请求；显式手动重新打开仍可显示窗口。
- 未更改 URL 路径、音频资源、音景归属、正式偏好或已有数据键。

## 已验证

- 全量 Swift 类型检查通过，目标 arm64/macOS 13；未生成 App。
- 新增/既有测试源码语法检查及 git diff --check 通过。
- 隔离逻辑探针通过：自动化先于启动、晚于启动但早于呈现、手动启动开关、显式重新打开、窗口请求只消费一次、关闭一个窗口仍有其他窗口时保留 Dock、最后窗口隐藏后隐藏 Dock。探针未显示窗口或访问用户数据。
- 窗口场景版本兼容写法先经独立最小类型检查，再用于项目；此前无效试写没有保留在正式源码。
- 系统启动键名以当前 SDK 为准；探针剔除未参与规则测试的 SwiftUI 场景代码，避免临时执行器无法解析版本检测符号。该问题不作为应用构建或运行失败记录。

## 未验证与下一步

- 尚未构建/启动独立 App，未跑完整 XCTest，未提交或推送。
- URL 冷启动的真实命令转发、窗口与 Dock 是否闪现，必须实机验证；不能以逻辑探针替代。
- 需要验证后台热启动、手动启动/重开、菜单栏主窗口/设置、两窗口交替关闭、关闭窗口后播放仍继续。
- 下一步在用户明确允许后，只构建一次新标识、独立数据、独立测试 URL 的副本，避免接管正式 whitenoise URL 或修改正式数据。
- 旧版 macOS 实机、登录项启动与系统窗口恢复的边界仍未验证。

## 依据

- Apple LSUIElement：https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/LaunchServicesKeys.html
- Apple 启动默认性标志：https://developer.apple.com/documentation/appkit/nsapplication/launchisdefaultuserinfokey
- Apple 场景默认启动行为：https://developer.apple.com/documentation/swiftui/scene/defaultlaunchbehavior(_:)
- 本机 Xcode SDK 的 AppKit/SwiftUI 公开接口与可用版本。


## 独立测试构建与当前阻断（2026-11-17）

用户明确允许一次构建。已在 `/private/tmp/sleepaid-silent-test-20261117/snapshot/` 复制源码，只在临时副本替换为 `whitenoise-silent-test` 并加入启动诊断；正式源码没有测试协议或日志。测试标识 `com.rey.whitenoise.uitestsilent20261117`，测试音量为0，手动启动打开主界面偏好保持开启。

- 唯一一次 App 构建成功；日志 `build.log`，测试副本 `白噪音静默启动测试.app`；签名及 Info.plist 检查通过。
- 只注册专用协议，未注册正式 whitenoise 地址；未启动测试 App 后先核对无旧进程。
- 已准备本机只读测试链接页；浏览器自动化点击专用协议被工具安全策略明确拒绝。该拒绝不是 App 或用户拒绝，未更换浏览器或命令绕过。
- 已请求用户手动打开 `whitenoise-silent-test://shortcut/start-sleep`，然后继续读取应用自身的 `runtime.jsonl` 和界面状态。
- 尚未完成真实冷启动、Dock/窗口不闪现、菜单栏手动打开和关闭持续播放验证；不把构建或逻辑探针写成这些项目通过。
- 后续不得擅自追加 App 构建；测试域、独立地址与副本保留供本次验证。


## 测试协议安装位置修正（2026-11-18）

用户手动触发后，快捷指令提示专用协议对应 App 未安装。检查确认临时 App 文件和签名正常，Launch Services 原始登记中已有声明，但 NSWorkspace 实际 URL 解析返回 NO_HANDLER。

- 对比控制：在原临时路径重新登记，解析仍为 NO_HANDLER。
- 仅改变安装位置：把同一个二进制复制到 `/Users/rey/Applications/白噪音静默启动测试.app`，验证二进制哈希相同、签名有效，再注销临时路径并登记用户应用目录副本。
- 同一只读查询现在按协议和 Bundle ID 均返回该用户应用目录路径。没有重建或启动 App，正式 App 未覆盖，正式协议未登记到测试副本。
- 测试数据仍使用原独立标识；诊断日志仍写入原临时证据目录。
- 已请求用户再次手动触发同一专用地址。浏览器自动跳转安全限制继续遵守，不用其他表面或命令绕过触发。
- 验收后必须额外清理用户应用目录中的该独立测试副本及其登记；保留正式 App 与偏好。
- 冷启动行为仍待实际触发后验证，不能把地址解析成功记为播放或 Dock 测试通过。


## 首次真实冷启动结果与修正（2026-11-18）

用户回复“已触发”后读取首次运行记录，进程PID 5822：启动阶段43条记录中 Dock policy 均为 accessory（1），没有手动开窗请求，但41条记录有可见“助眠”窗口；did-finish 的 defaultLaunch=false，command-start-sleep 的实时播放状态为“正在播放”。应用自身未隐藏，也未激活到前台。冷启动前 CUA 未找到测试进程，之后 NSWorkspace 只读确认该进程存在。

结论：命令接入与播放通过，启动阶段不出现 Dock 通过；无主窗口启动未通过，不作总体通过结论。证据 `runtime.jsonl` 和 `first-runtime-summary.json` 保留。

已完成的附加检查：手动点击主界面设置入口后，诊断记录 Dock policy=regular（0），可见窗口为“助眠”“设置”，确认手动打开设置恢复 Dock。切换窗口菜单时 CUA 控件失效，已停止反复点击；最后一个关窗保持播放、菜单栏主窗口入口等未在本轮完成实测。已用正常退出结束进程，并只读确认进程数为0。

原因定位：我漏掉了 SwiftUI 外部 URL 的窗口匹配限制。defaultLaunchBehavior 只限制默认启动；外部 URL 另按匹配规则寻找窗口，未限制的场景可能成为兜底窗口。首次记录中没有 present-main-request/dock-shown，主窗口在应用命令回调之前可见，符合框架外部事件窗口路由。

最小修正已写入：主窗口和设置的 View 使用空 preferring/allowing 集合，Scene 使用空 matching 集合；既阻止新建，也阻止复用已隐藏窗口。AppDelegate 仍处理有效自动化 URL。原有后台标记与默认启动/恢复抑制保留。

该修正已通过全量源码类型检查，尚未生成新 App。用户批准的一次构建已用完，等待明确同意再构建一次验证，不擅自追加。

依据：[Apple 外部事件窗口匹配说明](https://developer.apple.com/documentation/swiftui/scene/handlesexternalevents(matching:)) 与本机 SDK 公开接口。


## URL 窗口匹配修正版构建（2026-11-18）

用户明确允许再构建一次。已在 snapshot-v2 使用最新源码的 Scene/View 空外部事件匹配限制，并沿用专用协议及当前测试数据；诊断改写入 runtime-v2.jsonl，保留原失败日志。新版诊断同时记录所有可见窗口类别，避免漏计非标题栏弹层。

- 本次获批准的一次构建成功，日志 external-routing-build.log。
- 更新用户应用目录时，注销临时构建副本返回未登记错误，未影响已完成的编译；仅补齐用户目录的协议登记，未重建。
- 曾用重签名前后的完整二进制哈希作一致性判断，该判断不适合此场景，未作为分发失败结论；改为核对实际代码载体 SleepAidApp.debug.dylib 的编译 UUID 与有效签名。主 SleepAidApp 为调试加载壳，新旧 UUID 相同，不能用来证明代码更新。
- 新代码库 UUID 1C7FD2DC-F7C5-30F5-8E39-D5BF66BB35DE，用户目录与构建产物一致；旧代码库 UUID 8979C0AC-2ABF-3C4B-BD95-0744F280B095。旧副本已保存至 user-app-before-url-fix.app。
- 系统实际 URL 解析仍指向 /Users/rey/Applications/白噪音静默启动测试.app；只读确认进程数0，等待用户再次手动触发同一地址。未自动跳转协议，继续遵守浏览器工具限制。
- 本节尚无修正版冷启动通过结论；不以编译/分发成功替代运行验证。


## 修正版运行验证结果（2026-11-18，待用户验收）

证据：runtime-v2.jsonl 与 verified-runtime-v2-summary.json，均在独立临时测试目录。

### 已实测

1. 用户从完全无测试进程状态手动打开专用播放 URL，进程 PID 8256。首次43条启动记录的 Dock policy 全为 accessory（1），无标题窗口，全部可见窗口类别只有 NSStatusBarWindow；did-finish defaultLaunch=false，播放命令实时状态“正在播放”，App 未变为前台。主窗口、设置窗口和菜单弹层没有在冷启动样本中出现。
2. CUA getApp 连接无窗口后台 App 时实际触发了重新打开 App 的请求，日志明确记录 present-main-request，然后 Dock regular（0）、主窗口可见。此步骤与先前冷启动样本分开，记为显式重开测试，不能当作只读检查。后续无窗口观测只用日志与只读进程状态。
3. 手动点击主界面的设置入口，设置及主窗口同时可见，Dock 显示。关闭设置后主窗口仍在，实际进程激活策略保持 regular（0）。
4. 再关闭最后的主窗口，应用自身 dock-hidden 记录中标题窗口为空，实际进程仍存活且为 accessory（1）。
5. 用户手动打开状态查询 URL，同一 PID 8256 返回实时播放状态“正在播放”，标题窗口仍为空，Dock 仍为 accessory（1）。验证关窗后播放状态持续，以及已有隐藏窗口不会被后台 URL 再次拉出来。测试音量为0，未验证听感/音质。
6. 正常退出该进程后，通过正常应用打开动作启动同一测试版，新 PID 9373。did-finish defaultLaunch=true，主窗口请求一次，主窗口可见且 Dock regular（0）；界面空闲，没有自动播放。再次关闭主窗口后恢复 accessory（1），无标题窗口。

### 当前保留状态与限制

- 测试 App 保持后台、空闲、静音状态，供用户验收；正式 App 未替换，原正式自动化仍使用旧安装版。
- 本轮没有继续构建、提交或推送。专用 URL 的浏览器自动跳转限制未绕过，均由用户手动触发。
- 菜单栏两个直接按钮未逐一点击（已核对同一开窗/Dock通路的重开与主界面设置入口）；手动启动偏好关闭时的实机路径、旧系统、完整 XCTest 与登录项启动仍未实测。
- 正式 WhiteNoise.AppSettings.v1 与构建前备份相同。隔夜对比发现正式窗口位置、分栏位置、快捷指令状态键有变化，当前正式 App 也在运行；未核实这些运行记录的具体更新来源，不作“全部偏好字节一致”的结论，没有还原或覆盖它们。
- 验收通过后应正常退出并清理用户Applications测试副本、临时 App/快照/DerivedData、测试域、专用URL登记与本机测试页服务。测试页曾监听127.0.0.1:50548（执行会话76091），需核实归属后正常停止；保留日志及偏好备份，不触碰正式App。
