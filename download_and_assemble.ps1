<#
Requires: PowerShell 7+, Internet access.
说明：脚本读取 manifest/programs.json，对每个 direct_url 进行下载（若没有 direct_url 会提示用户输入），并将文件保存到 portable\<program>\<platform>。 #>

param(
  [string]$RepoRoot = (Split-Path -Parent $MyInvocation.MyCommand.Path)
)

$Manifest = Join-Path $RepoRoot "manifest\programs.json"
$PortableDir = Join-Path $RepoRoot "portable"
$BuildDir = Join-Path $RepoRoot "build"
$Checksums = Join-Path $RepoRoot "checksums.txt"

if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
  Write-Host "推荐安装 jq 或使用 PowerShell 的 ConvertFrom-Json 读取 manifest。脚本将使用 ConvertFrom-Json。"
}

$json = Get-Content $Manifest -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Force -Path $PortableDir, $BuildDir | Out-Null

foreach ($prog in $json.programs) {
  $id = $prog.id
  $name = $prog.name
  Write-Host "处理: $name ($id)"
  foreach ($pf in $prog.platforms) {
    $platform = $pf.platform
    $direct = $pf.direct_url
    $download_page = $pf.download_page
    $targetDir = Join-Path $PortableDir "$id\$platform"
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    if ($direct -and $direct -ne "") {
      $filename = Split-Path $direct -Leaf
      $out = Join-Path $targetDir $filename
      Write-Host "下载 $direct -> $out"
      Invoke-WebRequest -Uri $direct -OutFile $out -UseBasicParsing
      # 如果有 checksum_url，可在此处下载并校验（略）
    } else {
      Write-Host "manifest 未提供 direct_url。请打开官方下载页以获取下载链接： $download_page"
      $userurl = Read-Host "请输入直接下载 URL（或直接回车跳过）"
      if ($userurl -and $userurl -ne "") {
        $filename = Split-Path $userurl -Leaf
        $out = Join-Path $targetDir $filename
        Invoke-WebRequest -Uri $userurl -OutFile $out -UseBasicParsing
        Write-Host "已下载到 $out，建议手动校验 SHA256"
      } else {
        Write-Host "已跳过 $id / $platform"
      }
    }
  }
}

# 打包
$zipName = Join-Path $BuildDir ("梯子-portable-{0}.zip" -f (Get-Date -Format "yyyyMMddTHHmmssZ"))
Write-Host "正在打包 portable -> $zipName"
if (Get-Command Compress-Archive -ErrorAction SilentlyContinue) {
  Compress-Archive -Path (Join-Path $PortableDir "*") -DestinationPath $zipName -Force
} else {
  Write-Host "Compress-Archive 不可用，请手动打包 portable/ 目录。"
}
Write-Host "完成。最终 ZIP: $zipName"