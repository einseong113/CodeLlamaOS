# QEMU 로 빌드한 ISO 를 부팅해 본다 (QEMU for Windows 필요: https://www.qemu.org/download/#windows)
#   .\run-vm.ps1 -MemGB 8 -Cpus 4
param(
    [string]$Iso = "",
    [int]$MemGB = 8,
    [int]$Cpus = 4
)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not $Iso) {
    $found = Get-ChildItem out\*.iso -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $found) { Write-Error "out\ 에 ISO 가 없습니다. 먼저 .\build.ps1 을 실행하세요." }
    $Iso = $found.FullName
}

$qemu = (Get-Command qemu-system-x86_64 -ErrorAction SilentlyContinue).Source
if (-not $qemu) { $qemu = "C:\Program Files\qemu\qemu-system-x86_64.exe" }
if (-not (Test-Path $qemu)) { Write-Error "QEMU 를 찾을 수 없습니다. 설치하거나 VirtualBox/VMware 를 사용하세요." }

# 모델 파일 보관용 가상 디스크 (없으면 생성) - 라이브 세션은 RAM 위에서 돌기 때문
$disk = "out\data.qcow2"
if (-not (Test-Path $disk)) { & (Join-Path (Split-Path $qemu) "qemu-img.exe") create -f qcow2 $disk 40G | Out-Null }

# whpx: Windows Hypervisor Platform (켜져 있어야 빠름). 안 되면 -accel tcg 로 바꾸세요 (매우 느림).
& $qemu -m "${MemGB}G" -smp $Cpus -cpu max -accel whpx `
    -cdrom $Iso -boot d `
    -drive "file=$disk,if=virtio" `
    -device virtio-vga -display gtk `
    -nic user,model=virtio-net-pci,hostfwd=tcp::8080-:8080,hostfwd=tcp::2222-:22
