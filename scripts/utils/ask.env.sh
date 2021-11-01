ask() {
    local mode="$1"
    local type="$2"
    local var="$3"
    local prompt="$4"
    local default="$5"

    local optional
    local read_args

    [[ -n "${!var}" ]] && default="${!var}"

    case "$type" in
        value)
            prompt="${prompt}$([[ -n "$default" ]] && echo -e " [$default]" || true)"
            ;;
        secret)
            read_args="-s"
            prompt="${prompt}$([[ -n "$default" ]] && echo -e " [press enter to use existing value]")"
            ;;
        *)
            echo "Unsupported type: $type" >&2
            exit 1
            ;;
    esac
    case "$mode" in
        mandatory) ;;
        optional)
            optional="1"
            ;;
        *)
            echo "Unsupported mode: $mode" >&2
            exit 1
            ;;
    esac

    read ${read_args} -p "${prompt}: " $var

    export $var="${!var:-$default}"
    if [[ -z "${!var}${optional}" ]]; then
        error "Invalid value: Do not leave blank"
        exit 1
    fi
}