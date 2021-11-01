process_template() {
    local template
    local file

    template="$1"
    file="$(dirname "$1")/tmp/$(basename "$1" | sed -e 's:\.template\.:.secret.:')"
    file="${2:-$file}"

    mkdir -p "$(dirname "$file")"
    envsubst < "$template" > "$file"
    chmod 600 "$file"
}
