list_disks() {
    lsblk -l -o NAME,TYPE | grep -E "\sdisk$" | cut -d" " -f1
}


wait_for_disk() {
    # Wait for the disk to be inserted
    DISK_COUNT="$(list_disks | wc -l)"
    DISK_LIST="$(list_disks | sed "s:.*:^\0$:" | tr "\n" "|")"
    DISK_LIST="${DISK_LIST%?}"
    info "Insert the disk to continue"
    while [[ $(list_disks | wc -l) -eq "$DISK_COUNT" ]]; do
        sleep 1
    done
    DISK="/dev/$(list_disks | grep -E -v $DISK_LIST)"

    # Give the OS some time to automount partitions
    info "Disk found: $DISK"
}


get_disk() {
    if [[ -n "$DISK" ]]; then
        if [[ ! -e "$DISK" ]]; then
            error "$DISK not found" >&2
            exit 1
        fi
    else
        wait_for_disk
    fi

    # Check that the boot disk was not found by mistakea
    if [[ $(df | grep "$DISK" | grep -c " /boot") != "0" ]]; then
        error "Something unexpected happened. Try again." >&2
        exit 1
    fi
}


get_user_confirmation() {
    # Warn user before wiping the disk
    info "All data on $DISK is going to be lost."
    while true; do
        [[ -z "$FORCE" ]] || break
        read -r -p "Do you want to continue? [y|N]: " ANSWER
        ANSWER="${ANSWER:-n}"
        case "$ANSWER" in
            y|Y) break ;;
            n|N) echo "[Interrupted]"; exit 0;;
        esac
    done

    # Give some time for a CTRL-C if user changed their mind or used --force
    # by mistake.
    # Also gives some tome to the OS to mount the disk if the disk was just plugged in
    sleep 10
}


get_partitions() {
    df | grep -E "^${DISK}p?[0-9]+\s" | cut -d" " -f1
}


unmount_partitions() {
    while [[ "$(get_partitions | wc -l)" != "0" ]]; do
        for PARTITION in "$(get_partitions)"; do
            umount -l $PARTITION || true
            umount -f $PARTITION || true
        done
        sleep 3
    done
}
