info() {
    local message
    message=$1
    echo -e "$(date +%H:%M:%S)\t${message}"
}

error() {
    local message
    message=$1
    info "[ERROR] ${message}"
}
