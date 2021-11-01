#!/bin/bash -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
PROJECT_DIR="$(cd "$(dirname "$0")/../../.."; pwd)"

source "${PROJECT_DIR}/scripts/utils.env.sh"

generate() {
    local template
    local default_user__ssh__authorized_keys

    template="${SCRIPT_DIR}/user-data.template.yml"

    ask mandatory value hostname "Hostname" "rpi"
    ask mandatory value default_user "User" "pi"
    export default_user__ssh__authorized_keys="$(get_ssh_public_key)"

    process_template "$template"
}

generate
echo
echo "[OK]"
