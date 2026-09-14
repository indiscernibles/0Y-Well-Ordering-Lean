# 0-Y 与 BMS：可逆性、序同构及良序性

本项目给出 0-Y 与 BM4（Bashicu Matrix System）的数学证明及 Lean 4.33.1 形式化。编码、解码和 0-Y 展开均独立定义；结论不以任何外部互译程序的正确性为前提。

## 已证明的结论

- 对所有合法 0-Y 表达式，先编码再解码恢复原式。
- BMS 矩阵可逆，当且仅当满足深度正规性与阻挡条件 S。矩阵的共同尾零行视为同一表示。
- 全部合法 0-Y 式与全部可逆 BMS 矩阵序同构，包括非标准式；编码还保持并反映展开路径。
- 标准生成集以及任意固定合法起点的展开后代集按字典序良序。
- 从任意合法起点出发，无论逐步如何选择自然数指标，展开最终到达空式。
- 完整坏部与 Wiki 有限端点两种展开约定的可达闭包相同；两者都有上述良序性和终止性。

**全体合法表达式的字典序不良基。** 例如 `(1,2) > (1,1,2) > (1,1,1,2) > …`。这一反例也已形式化；良序结论的范围是标准生成集或固定起点的后代集。

## 阅读入口

- [完整数学证明](0Y-BMS-equivalence-proof.md)：定义、可逆充要条件及普通数学论证。
- [形式化说明](formalization/README.md)：各结论对应的 Lean 声明。
- [最终具体模型定理](formalization/Concrete/ZeroYConcrete.lean)：13 个最终定理，使用已构造的模型，无需调用者额外提供降界系统。
- [实际验证记录](formalization/VALIDATION.md)：构建结果、公理审计和依赖说明。
- [上游接口与非标准推广审计](research/formalization-bms-interface-audit.md)。

2026-09-10，核心构建通过 66 个任务，包含具体模型的完整构建通过 1576 个任务；合计 57 项关键声明的公理依赖审计通过，仅依赖 `propext`、`Classical.choice`、`Quot.sound` 的子集，无 `sorryAx` 或自定义公理。57 项包含具体模型和辅助定义，不是 57 个独立数学定理。

## 在 Windows 上复现

准备 Git、PowerShell 7、`curl.exe` 和 `tar.exe`。在本仓库根目录执行：

```powershell
./formalization/prepare-toolchain.ps1
./formalization/prepare-dependencies.ps1
./formalization/build.ps1
./formalization/Concrete/build.ps1
```

便携 Lean 安装在仓库的 `.tools` 中。依赖准备脚本按 [锁定记录](formalization/Concrete/dependencies-lock.json) 恢复源码，并应用两个保持公开陈述不变的上游证明性能补丁。下载归档会检查 SHA256。源码依赖和构建产物不提交到本仓库。

具体工程的构建脚本还执行 14 项公理白名单审计。核心的 43 项审计在 `formalization` 目录运行：

```powershell
../.tools/lean-4.33.1-windows/bin/lake.exe env lean Audit.lean
```

在 VS Code 中打开 `formalization/Concrete` 文件夹，再打开 `ZeroYConcrete.lean`，以使用完整依赖环境。若 Lean 扩展通过 elan 管理工具链，可在仓库根目录将便携运行时登记为同名工具链：

```powershell
elan toolchain link leanprover/lean4:v4.33.1 ./.tools/lean-4.33.1-windows
```

完整依赖的首次源码构建需要较多内存和时间；具体工程默认单线程。本次验证使用 Windows 与 Lean 4.33.1；其他系统的安装路径尚未验证。恢复脚本的验证范围见 [验证记录](formalization/VALIDATION.md)。

## 上游工作

良序模型复用 [EgoFakeFantasy/BMS-Well-Ordering-Lean](https://github.com/EgoFakeFantasy/BMS-Well-Ordering-Lean) 的构造宇宙桥接，固定于 `bae7e3d741f24a56d80da9b99c1345562cd10c2d`，并附有两个证明性能补丁。具体模型的其他依赖包括 constructible-universe 与 mathlib；准确来源和提交均见锁定记录。

数学背景参见 Rachel Hunter 的 [Well-Orderedness of the Bashicu Matrix System](https://arxiv.org/abs/2307.04606) 以及 [Googology Wiki 的 0-Y 定义](https://wiki.googology.top/index.php/0-Y)。原论文、外部 HTML、依赖源码归档和本机诊断材料不包含在发布文件中。

本仓库保留既有的 [Apache-2.0 许可证](LICENSE)；外部依赖保留各自的许可与来源信息。
