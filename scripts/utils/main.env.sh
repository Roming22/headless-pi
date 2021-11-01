main() {
    parse_args "$@"

    install

    info "The device is ejected and can be safely removed."
    echo
    echo "[OK]"
}
