# 本机能力与验证范围

核对日期：2026-11-08。本页描述已安装环境，不宣称 6.8.0 是当日最新发布；本次没有升级运行时。

## 版本与身份

| 项目 | 本次核对结果 |
| --- | --- |
| 工作台 CLI / 生产 MCP | `rea-agents 6.8.0` |
| MCP 自检 | healthy；229/229 工具、6/6 提示词；无 stderr |
| 当前聊天工具目录 | 229 项 REA 工具 |
| CLI 目录 | 175 个命令，来源为 server identity，不是逐个执行 |
| 已安装技能 | `reverse-engineer-anything`，包内版本 49 |
| 官方稳定版源码锚点 | `rea-agents-6.8.0` / `160d821ac9a0310afcb8d1fc427862dd6508add5` |
| 源码与运行时 | fork 的 main 已合并过较新的官方源码；发布包运行时仍独立固定在 6.8.0 |

本地源码曾因网络失败停留在工作台整合提交；不能用本地 HEAD 推断远端 main，或用远端 main 推断实际 MCP 运行版本。本次知识文档以远端实际主分支为发布基线。

## 选用顺序

| 输入或任务 | 可用路线 | 本机证据与限制 |
| --- | --- | --- |
| 容器、安装包、嵌入文件 | artifact inventory / inspect / extract | LÖVE 案例有真实提取和逐文件校验；不能把目录节点数当文件数 |
| .NET / Unity Mono DLL | managed artifact、members、CIL、native boundaries | 有真实静态检查；C# 导出由独立 ILSpy / AssetRipper 等完成，REA 元数据检查不是执行程序集 |
| Unity IL2CPP | `inspect_il2cpp_metadata`，可选匹配原生库 | 历史元数据 31 实测通过；原生地址关联没有在这份样本上验证 |
| Android APK / DEX | 包结构、Manifest、类/方法/引用、资源与签名声明 | 有历史 APK / Java 静态案例；各路线对 JADX、Apktool、ADB 的要求分别判断 |
| 原生 PE / ELF 等 | 导出、导入、资源、证书、结构检查；合适 provider 的反编译 | Windows 试玩包有 PE 检查；不能把安装器的代码当游戏逻辑 |
| 函数与版本比较 | 分析视图、函数匹配、批量反编译 | 官方能力；本次没有执行跨版本等价性或批量原生反编译验收 |
| 浏览器与网页 API | CDP、HAR、AgentEnv build / serve / compare / export | 官方能力；本机本次没有网页 AgentEnv 的独立运行验收 |
| 动态进程 / Frida / 调试器 | 以明确目标与相应外部引擎为条件 | 有工具接口不代表已安装、连接或验证；不能默认执行目标 |
| 其他格式 | pyc、BEAM、模型、GPU、设备树、内核模块、Apple IPS 等 | 属于通用目录覆盖，本次没有对应真实样本验收 |

## 本机外部工具与宿主限制

本次工作台能力探测确认 Ghidra 12.1.4 + JDK 21 的启动条件可用，但未打开目标，`target_support` 仍未知。Windows Ghidra P0 只接纳其列明的 native PE / 显式 raw 6502 路线，不接受数据库修改；这与内建 IL2CPP 读取是两条路线。不能把一个 Android ELF 可静态检查，推导为 Windows REA Ghidra 可对它执行反编译。

Hopper 在 Windows 不支持；IDA、Kuna 当前未配置。此前本机记录有 JADX 和独立 AssetRipper、UnityPy、Il2CppDumper、Cpp2IL、ILSpy；它们不是此 fork 自研的分析器，也没有在本次全部重跑。ADB / Apktool 曾有 PATH 未解析记录，本次没有复测修复，仍按待验证处理。

## IL2CPP 实测的准确含义

2026-10-28 的只读元数据 31 检查得到 148 images、30,057 types、217,190 methods、130,405 fields、38,018 string literals。原始 Evidence 留本地。

该次请求没有提供 native binary，报告的 `binary`、方法地址与部分类型关联计数为 `null`，表示未求证，不能写成 0 或已恢复。声明规模不是原 C# 方法体、原生执行行为或完整 Unity 工程的恢复量。

官方 6.8.0 支持的元数据版本为 24 / 27 / 29 / 31 / 39，具体变体、64 位链接格式及重定位限制以[固定版本说明](https://github.com/morluto/rea/blob/rea-agents-6.8.0/docs/il2cpp-metadata.md)为准。

## 6.8.0 调用注意

- MCP `analyze_function` 默认摘要；完整内容显式选择 `detail=complete`，后续使用保留证据分页。
- JSONL 含控制记录；旧版整 JSON 消费者改用 JSON 或识别新 framing。
- 声明、静态推导、运行结果和交付结论分别记录；重建验收要绑定实现版本和逐项主张。
- 签名/证书结构、摘要自洽与密码学验签、信任链、平台接受性分别判断。
- 摘要输出更短不证明更快；本次没有新旧 CPU、内存、时间或 token 对照。

原始版本依据：[6.8.0 更新日志](https://github.com/morluto/rea/blob/rea-agents-6.8.0/CHANGELOG.md)、[AgentEnv](https://github.com/morluto/rea/blob/rea-agents-6.8.0/docs/agent-environments.md)。
