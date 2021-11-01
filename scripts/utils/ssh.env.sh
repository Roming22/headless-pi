get_ssh_public_key() {
    local cipher
    local private_key
    local public_key

    cipher="ed25519"
    private_key="${HOME}/.ssh/id_${cipher}"
    public_key="${private_key}.pub"
    if [[ ! -e "$public_key" ]]; then
        generate_ssh_key >/dev/null 2>&1
    fi

    cat "$public_key" | head -1
}

generate_ssh_key() {
    info "Generating a key pair for SSH"
    echo "


" | ssh-keygen -a 100 -f "${private_key}" -o -t "${cipher}" -C "${USER}@$(date +"%Y%m%d")"
}