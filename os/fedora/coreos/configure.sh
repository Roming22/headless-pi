#!/bin/bash -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
PROJECT_DIR="$(cd "$(dirname "$0")/../../.."; pwd)"

source "${PROJECT_DIR}/scripts/utils.env.sh"


generate() {
    local template
    local ssh_public_key

    template="${SCRIPT_DIR}/user-data.template.ign"

    ask mandatory value hostname "hostname" "rpi"
    ask mandatory value default_user "user" "pi"
    export ssh_public_key=$(get_ssh_public_key)

    process_template "$template"
}

generate
echo
echo "[OK]"
