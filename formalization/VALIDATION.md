# 验证记录

日期：2026-09-10。以下路径均相对于本仓库。

## 编译环境

```text
Lean (version 4.33.1, x86_64-w64-windows-gnu,
commit 819816b2e0a3bf405af45ae5c7af2491d8f5bee6, Release)
```

上游 BMS 基线提交：`bae7e3d741f24a56d80da9b99c1345562cd10c2d`。核心没有新增外部库依赖。具体模型接入另有两个证明脚本性能补丁：[StageStableBetweenFormula](Concrete/patches/stage-stable-between-performance.patch) 和 [StageStableToUniverseFormula](Concrete/patches/stage-stable-to-universe-performance.patch)。两者将证明方向拆为独立辅助定理，先对任意公式证明外层语义桥，再用等价传递装配公开定理，并同步执行内核检查；第一个文件还删除两条递归化简，使用小元组等式作显式传输。这些改动避免比较大型语义表达式时的内存膨胀。公开定理陈述、公式定义和假设均未改变，没有关闭或跳过任何验证。准确补丁、基线提交和改动前后 SHA256 见 [具体模型说明](Concrete/README.md)；原始源码可从基线提交恢复。

## 已实际完成的核心合并检查

工作区根目录运行：

```powershell
./formalization/build.ps1
```

结果：`Build completed successfully (66 jobs).`，无错误、无警告。入口已合并完整往返、原始及规范矩阵可逆充要条件、全域序同构、I/S 展开保持、独立算法展开交换、标准生成集及任意固定起点后代集对应，以及全部 Wiki 桥接和终止定理。

`ZeroY.Dynamics.Termination` 和 `ZeroY.Wiki.Termination` 提供任意合法起点、任意指标序列的实际迭代最终到达空式。核心保留显式的 `RepresentationDescentSystem frame` 参数；下述具体工程已实际构造并代入该系统，完成无需额外模型参数的结论。

## 实际公理依赖审计

在 `formalization` 中运行 `lake env lean Audit.lean`，退出码 0，检查 43 个指定声明。可复现清单位于 [Audit.lean](Audit.lean)，实际输出见 [audit-output.txt](audit-output.txt)。

其中包括：

```text
ZeroY.decode_encode
ZeroY.encode_lt_iff
ZeroY.roundTrip_iff_structural
ZeroY.reversibleOrderIso
ZeroY.BMS.structural_expand
ZeroY.encode_expandY
ZeroY.decode_expand
ZeroY.encode_seed
ZeroY.generatedOrderIso
ZeroY.descendantOrderIso
ZeroY.yStep_wellFounded
ZeroY.no_infinite_yStep_chain
ZeroY.yGenerated_strictWellOrder
ZeroY.yDescendants_strictWellOrder
```

这些声明的实际依赖均为 `propext`、`Classical.choice`、`Quot.sound`。其余基础声明只依赖这个集合的子集；两个通用传输声明没有公理依赖。全部 43 项均无 `sorryAx`、原生计算公理或自定义公理。

静态搜索 `formalization/ZeroY/**/*.lean` 的 `sorry`、`admit`、`axiom` 也未发现声明或占位。静态搜索本身不能代替上面的内核编译及公理依赖检查。

## 已实际完成的具体模型接入

在 `formalization/Concrete` 中运行：

```powershell
./build.ps1
```

完整源码构建的实际结果为 `Build completed successfully (1576 jobs).`。[Concrete/ZeroYConcrete.lean](Concrete/ZeroYConcrete.lean) 的 13 个最终定理均已编译通过，包括 BMS 与 0-Y 的展开良基性、标准集及任意固定起点后代集的字典序良序性，以及两种 0-Y 约定下任意指标轨迹到达空式的终止性。它们不要求调用者提供降界系统。上游原有的未使用变量和战术风格警告保留，构建无错误。

随后实际运行 `./build.ps1 -AuditOnly`，退出码 0。脚本核对 [Concrete/Audit.lean](Concrete/Audit.lean) 的 14 项名称，无缺漏或重复，并逐项检查公理白名单。具体模型 `reflectionData_l` 自身及上述 13 个最终定理的依赖均恰为 `propext`、`Classical.choice`、`Quot.sound`。实际输出保存在 [Concrete/audit-output.txt](Concrete/audit-output.txt)，SHA256 为 `5f0b7cd4a11bb47037df253aa0fd7d22ded1b3f05c22454180d3b0fb2106c889`。

核心与具体工程合计 **57 项关键声明公理审计通过**，无 `sorryAx`、原生计算公理或自定义公理。最终模型已实际构造和检查，不再遗留模型存在性假设。

构造宇宙依赖固定于 `7f5a7d03d63d9769172f17350bbe8303996e5b53`，mathlib 固定于 `eba3d887fc52c98627f4b81507c0efc3096e91b9`。后两者原始工具链是 `4.33.0-rc1`；本次所需 Lean 证明源码全部使用 `4.33.1` 重建，没有复用其他版本的 `.olean`。完整依赖锁定、两个性能补丁的哈希与构建记录见 [dependencies-lock.json](Concrete/dependencies-lock.json)。

## 辅助样例（非证明前提）

[Examples.lean](Examples.lean) 的 `by decide` 检查覆盖空式、零指标、跨块边界、不可逆反例和共同尾零行。交付规格是独立定义的数学算法；这些样例和外部程序均不是全称定理的前提。

## 发布准备与恢复脚本检查

发布文件包括数学稿、Lean 源码、Lake 配置、锁定记录、构建与恢复脚本、两份性能补丁及最终公理审计输出。依赖源码、运行时、构建缓存、论文副本和本机诊断材料不随仓库提交。`.gitattributes` 保留补丁和审计输出的原始字节，避免 Git 换行转换改变其 SHA256。

2026-09-10，在 Windows / PowerShell 7 下实际检查 [prepare-dependencies.ps1](prepare-dependencies.ps1)：

- 全量 `-CheckOnly` 通过：11 项依赖、两个 Lake 路径清单、三个真实 Git 提交、八份缓存源码归档的 SHA256 及两份补丁对应的源码哈希。
- 在已有正确依赖上执行默认恢复模式通过，验证重复执行无需重新下载或改写已应用的补丁。
- 在隔离目录使用锁定的 LeanSearchClient 缓存归档，实际经过归档列表核验、解包、移动和临时目录清理，随后 `-CheckOnly` 通过。
- 从本地真实 Git 对象克隆干净 BMS 基线并检出固定提交，实际重新应用两份补丁；改动后源码哈希和随后 `-CheckOnly` 均通过。

这组测试验证恢复脚本的本地检查、解包与补丁路径；没有重新进行一轮“全新网络获取全部依赖后完整构建”的测试。前文的 1576 项源码构建与 57 项审计是已实际完成的数学证明验证。恢复脚本检查提交、配置、缓存归档和指定补丁的身份，不逐字验证所有已经解包的依赖文件。
