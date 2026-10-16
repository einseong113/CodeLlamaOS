#!/usr/bin/env bash
# 컨테이너(또는 Debian/Ubuntu 호스트) 안에서 ISO 를 빌드한다. root 필요.
#   SRC   : live/ 디렉터리 (기본 /src/live)
#   OUT   : ISO 출력 위치   (기본 /out)
#   LLAMA_CPP_REF    : llama.cpp 태그/브랜치 (기본: master 최신)
#   LLAMA_CMAKE_EXTRA: llama.cpp 추가 cmake 옵션 (예: "-DGGML_VULKAN=ON")
#   INSTALL_AIDER    : 1(기본) / 0
set -euo pipefail

SRC=${SRC:-/src/live}
OUT=${OUT:-/out}
WORK=${WORK:-/work}

# debootstrap 은 Windows 바인드 마운트 위에서 동작하지 않으므로 리눅스 파일시스템으로 복사
rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"
cp -a "$SRC"/. "$WORK"/
cd "$WORK"

# Windows 에서 편집되어 CRLF 가 섞였을 경우 + 실행 권한 복구
find . -type f -exec sed -i 's/\r$//' {} +
chmod +x auto/* config/hooks/live/* config/includes.chroot/usr/local/bin/*

mkdir -p config/includes.chroot/etc/codellama
cat > config/includes.chroot/etc/codellama/build.conf <<EOF
LLAMA_CPP_REF="${LLAMA_CPP_REF:-}"
LLAMA_CMAKE_EXTRA="${LLAMA_CMAKE_EXTRA:-}"
INSTALL_AIDER="${INSTALL_AIDER:-1}"
EOF

lb clean --purge >/dev/null 2>&1 || true
lb config
lb build

cp -v ./*.iso "$OUT"/
(cd "$OUT" && sha256sum ./*.iso | tee SHA256SUMS)
echo "완료: $OUT"
