param(
  [ValidateRange(1, 32)]
  [int]$Threads = 1,
  [switch]$AuditOnly
)

$ErrorActionPreference = 'Stop'
$taskLake = [System.IO.Path]::GetFullPath(
  (Join-Path $PSScriptRoot '../../.tools/lean-4.33.1-windows/bin/lake.exe'))
if (-not (Test-Path -LiteralPath $taskLake -PathType Leaf)) {
  throw "缺少本工程的 Lean 4.33.1：$taskLake"
}

$taskVersion = & $taskLake --version
if ($LASTEXITCODE -ne 0 -or $taskVersion -notmatch 'Lean version 4\.33\.1\)') {
  throw "工具链版本不符：$taskVersion"
}

$taskPreviousThreads = $env:LEAN_NUM_THREADS
Push-Location -LiteralPath $PSScriptRoot
try {
  $env:LEAN_NUM_THREADS = [string]$Threads
  # 全部证明源码由当前工具链检查，不加载其他 Lean 版本的构建缓存。
  if (-not $AuditOnly) {
    & $taskLake --keep-toolchain --no-cache build ZeroYConcrete 2>&1 |
      Tee-Object -FilePath '.lake/build-source.log' -Append
    if ($LASTEXITCODE -ne 0) {
      throw '具体模型构建失败；请查看 .lake/build-source.log。'
    }
  }

  # 在成功构建的实际导入环境中检查最终定理的公理依赖。
  & $taskLake env lean Audit.lean 2>&1 |
    Tee-Object -FilePath 'audit-output.txt'
  if ($LASTEXITCODE -ne 0) {
    throw '具体模型公理审计运行失败；请查看 audit-output.txt。'
  }

  $taskExpected = @(Get-Content -LiteralPath 'Audit.lean' | ForEach-Object {
    if ($_ -match '^#print axioms (\S+)\s*$') { $Matches[1] }
  })
  $taskAuditText = Get-Content -LiteralPath 'audit-output.txt' -Raw
  $taskAudits = [regex]::Matches($taskAuditText,
    "'(?<name>[^']+)' depends on axioms:\s*\[(?<axioms>[^\]]*)\]")
  if ($taskExpected.Count -ne 14 -or $taskAudits.Count -ne $taskExpected.Count) {
    throw "公理审计项目数量不符：应有14项，声明$($taskExpected.Count)项，输出$($taskAudits.Count)项。"
  }
  $taskSeen = @{}
  foreach ($taskAudit in $taskAudits) {
    $taskName = $taskAudit.Groups['name'].Value
    if ($taskName -notin $taskExpected -or $taskSeen.ContainsKey($taskName)) {
      throw "公理审计出现未知或重复项目：$taskName"
    }
    $taskSeen[$taskName] = $true
    foreach ($taskAxiom in ($taskAudit.Groups['axioms'].Value -split ',')) {
      $taskAxiom = $taskAxiom.Trim()
      if ($taskAxiom -and $taskAxiom -notin @('propext', 'Classical.choice', 'Quot.sound')) {
        throw "公理审计失败：$taskName 依赖非白名单公理 $taskAxiom"
      }
    }
  }
  Write-Output '具体模型和13个最终定理均通过公理白名单审计。'
}
finally {
  Pop-Location
  $env:LEAN_NUM_THREADS = $taskPreviousThreads
}
