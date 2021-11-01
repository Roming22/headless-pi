#!/bin/bash -e
set -o pipefail

usage() {
    ERROR="$1"
    [[ -z "${ERROR}" ]] || echo "$ERROR"
    echo "
Options:
  -d,--disk DISK    disk on which to install the OS
  -f,--force        do not ask for any confirmation
  -h,--help         show this message
  -v,--verbose      increase verbose level
"
    [[ -n "${ERROR}" ]] && exit 0 || exit 1
}


SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
PROJECT_DIR="$(cd "$(dirname "$0")/../../.."; pwd)"
DISK="$1"
IMAGES_DIR="${PROJECT_DIR}/images"
TMP_DIR="${SCRIPT_DIR}/tmp"
IGN_CONFIG="${TMP_DIR}/user-data.secret.ign"

source "${PROJECT_DIR}/scripts/utils.env.sh"

if [[ ! -e "${IGN_CONFIG}" ]]; then
    error 'Run "./os/configure.sh" first' >&2
    exit 1
fi

# Making sure the script is run as root
if [[ "$UID" != "0" ]]; then
    error "Run with sudo" >&2
    exit 1
fi


parse_args() {
    unset DISK
    unset ENABLE_ROOT
    unset FORCE
    ACTION="install"
    while [[ "$#" -gt "0" ]]; do
        case "$1" in
            -d|--disk) DISK=$2; shift ;;
            -f|--force) FORCE="1" ;;
            -h|--help) usage ;;
            -v|--verbose) set -x ;;
            *) usage "Unknown option: $1" ;;
        esac
        shift
    done
}


install_to_disk() {
    info "Installing OS to device..."
    get_user_confirmation
    unmount_partitions

    # Install OS
    sudo podman run --pull=always --privileged --rm \
        -v /dev:/dev -v /run/udev:/run/udev -v "${SCRIPT_DIR}/tmp:/data" -w /data \
        quay.io/coreos/coreos-installer:release \
        install "$DISK" --architecture aarch64 --ignition-file "$(basename "$IGN_CONFIG")" --platform metal
    sync

    # Refresh disk info
    partprobe "${DISK}"
}


copy_uefi() {
    RPI_FW_VERSION="v1.31"
    RPI_FW_URL="https://github.com/pftf/RPi4/releases/download/${RPI_FW_VERSION}/RPi4_UEFI_Firmware_${RPI_FW_VERSION}.zip"
    RPI_FW="${IMAGES_DIR}/RPi4_UEFI_Firmware_${RPI_FW_VERSION}.zip"
    [[ -e "$RPI_FW" ]] || curl --location --output "$RPI_FW" "$RPI_FW_URL"

    UEFI_DIR="$TMP_DIR/uefi"
    mkdir "$UEFI_DIR"
    mount "${DISK}2" "$UEFI_DIR"

    unzip -d "$UEFI_DIR" "$RPI_FW"
    echo -e "disable_splash=1" >> "${UEFI_DIR}/config.txt"

    umount "$UEFI_DIR"
    rmdir "$UEFI_DIR"
}


install() {
    get_disk
    install_to_disk
    copy_uefi
    unmount_partitions
}


if [ "$0" = "$BASH_SOURCE" ]; then
    main "$@"
fi
