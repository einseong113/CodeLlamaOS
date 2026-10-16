# Windows 에서 Docker Desktop 으로 CodeLlama OS ISO 를 빌드한다.
#   .\build.ps1                       # 기본 빌드
#   .\build.ps1 -LlamaRef b6000       # llama.cpp 태그 고정
#   .\build.ps1 -NoAider              # aider 제외 (ISO 가 작아짐)
#   .\build.ps1 -CmakeExtra "-DGGML_VULKAN=ON"
# 결과: .\out\codellama-os-amd64.hybrid.iso
param(
    [string]$LlamaRef = "",
    [string]$CmakeExtra = "",
    [switch]$NoAider
)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker 가 필요합니다. Docker Desktop 설치 후 다시 실행하세요 (또는 README 의 GitHub Actions 방법 사용)."
}
docker info *> $null
if ($LASTEXITCODE -ne 0) { Write-Error "Docker 데몬이 실행 중이 아닙니다. Docker Desktop 을 켜세요." }

New-Item -ItemType Directory -Force out | Out-Null

docker build -t codellama-os-builder .
if ($LASTEXITCODE -ne 0) { exit 1 }

$aider = if ($NoAider) { "0" } else { "1" }
Write-Host "ISO 빌드 시작 - 30~90분 걸릴 수 있습니다 (llama.cpp 컴파일 포함). 메모리 8GB+ 권장."
docker run --rm --privileged `
    -v "${PSScriptRoot}\live:/src/live:ro" `
    -v "${PSScriptRoot}\out:/out" `
    -e "LLAMA_CPP_REF=$LlamaRef" `
    -e "LLAMA_CMAKE_EXTRA=$CmakeExtra" `
    -e "INSTALL_AIDER=$aider" `
    codellama-os-builder
if ($LASTEXITCODE -ne 0) { Write-Error "빌드 실패" }

Get-ChildItem out\*.iso | Format-Table Name, @{n = "GB"; e = { [math]::Round($_.Length / 1GB, 2) } }
Write-Host "다음: .\run-vm.ps1  (QEMU)  또는 VirtualBox/VMware 에 ISO 연결, 또는 Rufus 로 USB 굽기"
