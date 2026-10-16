# ISO 빌드 도구 이미지 (Debian live-build). 소스는 실행 시 마운트한다.
FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        live-build debootstrap squashfs-tools xorriso mtools dosfstools \
        syslinux syslinux-common isolinux \
        grub-pc-bin grub-efi-amd64-bin grub-common \
        ca-certificates git curl gnupg \
    && rm -rf /var/lib/apt/lists/*

COPY build.sh /usr/local/bin/build-iso
RUN chmod +x /usr/local/bin/build-iso

ENTRYPOINT ["/usr/local/bin/build-iso"]
