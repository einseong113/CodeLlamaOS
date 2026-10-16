# CodeLlama OS

llama.cpp 가 기본 탑재된, **C++ / Python 코딩용 라이브 리눅스 OS** (Debian 12 기반, BIOS+UEFI 부팅 ISO).
커널을 처음부터 만드는 게 아니라, Debian 위에 개발 환경과 로컬 LLM 을 얹어 부팅 가능한 ISO 로 굽는 방식입니다.

## 들어있는 것

| 구분 | 내용 |
|---|---|
| LLM | llama.cpp (소스 빌드, `/opt/llama.cpp`). CPU 변형을 전부 빌드해 **실행 시 CPU 에 맞는 걸 자동 선택** (AVX2/AVX512 등) |
| C++ | g++ / clang, clangd, clang-format, clang-tidy, cmake, ninja, gdb, lldb, valgrind, ccache, cppcheck, gtest, fmt, libcurl, nlohmann-json |
| Python | python3 + pip/venv/pipx, ipython, pytest, black, flake8, mypy, pylsp, numpy |
| AI 도구 | `llm`(모델/서버 관리), `ask`(터미널 질문), `aider`(AI 페어 프로그래밍, 선택) |
| 편집기 | neovim(F5 = 저장 후 실행, clangd/pylsp 연동), micro, geany |
| 데스크톱 | XFCE, Firefox, 한글 입력(fcitx5-hangul), 한국어 로케일/키보드/시간대 기본값 |
| 설치 | Calamares (라이브 부팅 후 디스크 설치 가능) |

기본 계정: `dev` (라이브 기본 비밀번호는 `live`, sudo 가능).

## 1. ISO 빌드

**방법 A — Windows + Docker Desktop**
```powershell
.\build.ps1                      # 30~90분, 메모리 8GB+ 권장, 디스크 20GB+
.\build.ps1 -LlamaRef <태그>     # llama.cpp 버전 고정
.\build.ps1 -NoAider             # aider 제외
.\build.ps1 -CmakeExtra "-DGGML_VULKAN=ON"   # 백엔드 추가(추가 -dev 패키지 필요할 수 있음)
```
결과: `out\codellama-os-amd64.hybrid.iso`

**방법 B — GitHub Actions (로컬에 Docker 가 없을 때)**
이 폴더를 GitHub 저장소에 올리고 Actions 탭 → *Build ISO* → Run workflow → 아티팩트 다운로드.

**방법 C — Debian/Ubuntu 리눅스**
```bash
sudo apt install live-build debootstrap xorriso squashfs-tools mtools syslinux isolinux grub-pc-bin grub-efi-amd64-bin git
sudo SRC=$PWD/live OUT=$PWD/out ./build.sh
```

## 2. 실행

- **QEMU**: `.\run-vm.ps1` (8080 포트가 호스트로 포워딩됨)
- **VirtualBox/VMware**: ISO 연결, RAM 8GB+, CPU 4코어+, EFI 켜기
- **실기기**: Rufus(DD 모드) 또는 balenaEtcher 로 USB 에 굽기

## 3. 부팅 후 사용

```bash
llm list            # 내 RAM 기준 모델 추천 (qwen2.5-coder 1.5B/3B/7B/14B)
llm use medium      # 모델 선택 → 다운로드 → 서버 시작
ask "std::variant 와 union 차이?"
cat main.cpp | ask "버그 찾아줘"
cd ~/myproject && aider      # git 저장소에서 AI 페어 프로그래밍
```
- 웹 UI: http://127.0.0.1:8080, OpenAI 호환 API: `http://127.0.0.1:8080/v1` (`OPENAI_API_BASE` 가 이미 설정됨)
- 다른 모델: `llm use unsloth/SomeModel-GGUF:Q4_K_M` 또는 `llm use /경로/model.gguf`
- 설정: `/etc/codellama/llama.env` (컨텍스트 길이 `CTX`, 추가 인자 `EXTRA` 등)
- 예제: `~/examples` (C++ CMake 프로젝트, Python 클라이언트)

> **중요:** 라이브 세션은 RAM 위에서 동작해서 재부팅하면 내려받은 모델이 사라집니다.
> 계속 쓰려면 Calamares 로 **디스크에 설치**하거나, 모델 `.gguf` 를 별도 디스크에 두고 `llm use /경로` 로 지정하세요.
> VM 이라면 `run-vm.ps1` 이 만드는 `out\data.qcow2` 디스크를 파티션/마운트해 사용할 수 있습니다.

## 구조

```
live/auto/config                     lb 설정 (배포판, 부트로더, 부트 옵션)
live/config/package-lists/           설치 패키지 목록
live/config/hooks/live/0100-*        llama.cpp 소스 빌드
live/config/hooks/live/0200-*        aider 설치(선택)
live/config/includes.chroot/         ISO 에 그대로 들어가는 파일 (llm, ask, 서비스, 예제 등)
build.sh / Dockerfile / build.ps1    빌드 스크립트
```

## 알려둘 점

- 이 PC 에서 직접 빌드/부팅 검증은 못 했습니다(Docker/WSL 없음). `llm`, `ask` 는 문법 검사와 가짜 서버 대상 테스트만 거쳤고, llama.cpp 빌드 옵션은 최신 문서를 확인해 작성했습니다.
  첫 빌드에서 막히면 빌드 로그의 에러를 알려주세요.
- llama.cpp 는 기본으로 최신 master 를 받습니다. 재현 가능한 빌드가 필요하면 `-LlamaRef` 로 태그를 고정하세요.
- GPU(CUDA/Vulkan) 가속은 기본 미포함입니다. VM 에서는 어차피 CPU 추론이고, 실기기에서 쓰려면 `-CmakeExtra` 와 해당 패키지를 추가해야 합니다.
