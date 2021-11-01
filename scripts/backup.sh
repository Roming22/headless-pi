#!/bin/bash -e
set -o pipefail

usage() {
    ERROR="$1"
    [[ -z "${ERROR}" ]] || echo "$ERROR"
    echo "
Options:
  -d,--disk DISK    disk on which to install the OS
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
            -h|--help) usage ;;
            -v|--verbose) set -x ;;
            *) usage "Unknown option: $1" ;;
        esac
        shift
    done
}

backup() {
    local backup_dir
    local backup_path

    get_disk
    backup_dir="${PROJECT_DIR}/backups"
    backup_path="${backup_dir}/img.$(date +"%y%m%d-%H%M%S").xz"

    [[ -d "$backup_dir" ]] || mkdir -p "$backup_dir"
    sudo dd if="$DISK" status=progress | xz > "$backup_path"
    info "$DISK backed up to $backup_path"
}

parse_args "$@"
backup
echo "[OK]"
