#!/bin/bash -e
set -o pipefail

usage() {
    ERROR="$1"
    [[ -z "${ERROR}" ]] || echo "$ERROR"
    echo "
Options:
  -d,--disk DISK    disk on which to install the OS
  -i,--image        path of the xz compressed image
  -h,--help         show this message
  -v,--verbose      increase verbose level
"
    [[ -n "${ERROR}" ]] && exit 0 || exit 1
}

SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
PROJECT_DIR="$(cd "$(dirname "$0")/.."; pwd)"

source "${PROJECT_DIR}/scripts/utils.env.sh"


parse_args() {
    unset DISK
    while [[ "$#" -gt "0" ]]; do
        case "$1" in
            -d|--disk) DISK="$2"; shift ;;
            -i|--image) IMAGE_PATH="$2"; shift;;
            -h|--help) usage ;;
            -v|--verbose) set -x ;;
            *) usage "Unknown option: $1" ;;
        esac
        shift
    done
}

restore() {
    if [[ ! -e "$IMAGE_PATH" ]]; then
        error "$IMAGE_PATH not found"
        exit 1
    fi

    get_disk
    xzcat "$IMAGE_PATH" | sudo dd bs=4M of="${DISK}" status=progress
    sync
}

parse_args "$@"
restore "$@"