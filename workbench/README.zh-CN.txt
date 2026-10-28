REA Windows 工作台（基于官方 6.8.0）

本仓库保留 morluto/rea 的源码、上游说明和 MIT 许可证。workbench 仅整合本地安装、统一命令入口和验证流程，不替换上游分析器。

运行环境
Windows PowerShell 或 PowerShell 7；Node 满足 ^22.23.4、^24.22.1 或 >=26.12.1，另需现有 npm。
不会自动安装或升级 Node、Java、Ghidra、JADX、模拟器或其他分析引擎。
安装默认禁用 npm 生命周期脚本；Frida 等可选原生集成需另行确认，不宣称随此入口即可使用。

安装及使用（从仓库根目录执行）
1. .\workbench\Install-Workbench.ps1
2. .\workbench\rea.ps1 --version
3. .\workbench\Verify-Workbench.ps1
需要配置 Codex 时执行 .\workbench\Install-Workbench.ps1 -ConfigureCodex；先展示更新计划，再由官方 setup 确认。重启 Codex 后才能在原会话加载新版工具。
运行时从官方 rea-agents npm 下载，版本与仓库 package.json 一致；源代码修改的开发构建继续使用上游 README 的 npm ci / build 流程。

可选分析引擎
将 workbench/providers.example.json 复制到 .local/providers.json，改为本机真实路径。未配置的引擎仍不可用。
入口临时应用 REA_*、JAVA_HOME、GHIDRA_INSTALL_DIR、HOPPER_LAUNCHER_PATH，退出后恢复调用进程的原环境；不执行配置文件中的脚本。
Codex 的注册由 setup 固化路径和显式环境；移动目录后需重新生成计划和注册。工作台与官方直连 MCP 均应使用同一版本。

Unity IL2CPP
直接检查 global-metadata.dat；正式版支持元数据24、27、29、31、39，具体布局和链接限制见 docs/il2cpp-metadata.md。
示例：.\workbench\Verify-Workbench.ps1 -MetadataPath C:\samples\global-metadata.dat
可选 -BinaryPath 指定匹配的 libil2cpp.so 或 GameAssembly 原生库。仅同名文件不构成同构建证明。
完整 Evidence 和摘要写入 .local/verification，不覆盖旧结果，不上传样本。
元数据声明、静态方法地址和运行行为是不同证据；该工具不会自动还原完整Unity工程或保证战斗一致。

优先使用
托管DLL元数据/CIL锚点；Android Java/DEX；IL2CPP元数据；摘要和分页查询；明确样本身份后的原生分析。
资源恢复继续按任务使用 AssetRipper、UnityPy 等独立工具，不能把 DummyDll 当原 C# 方法体。
REA Windows Ghidra P0 的目标格式限制、ADB/Apktool路径和各可选引擎要求仍然生效。229项工具目录不等于229项均已对本机样本验证。

6.8.0迁移
MCP analyze_function 默认返回保留摘要；需要完整正文时显式 detail=complete。
JSONL增加独立控制记录；旧整JSON消费者使用 --format json。
验收需实现/版本绑定与逐项结论，不能仅以证据ID列表声明完成。

本机与仓库边界
源码、必要脚本、通用说明入库；.local、node_modules、安装包、配置、日志、私有APK/EXE、原生样本与分析证据留本地。
不要把旧游戏恢复脚本和原始视频/资源复制进此仓库。

验证范围（2026-10-28）
官方6.8.0发布包完整性校验通过；生产stdio MCP启动及229/229工具目录检查通过。
已对本机私有元数据31样本完成只读解析，完整原件保留本地；此项不证明原生地址匹配、运行行为或全量引擎可用。
工作台的语法、安装入口、统一CLI、环境恢复及MCP验证结果见提交时核对记录；未执行上游全量测试或编译全部源码。

上游与许可证
https://github.com/morluto/rea
https://github.com/morluto/rea/releases/tag/rea-agents-6.8.0
MIT 许可证见仓库 LICENSE。原作者及上游来源保持不变。
