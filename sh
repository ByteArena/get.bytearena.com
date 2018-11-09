#!/usr/bin/env bash

TARGET=/usr/local/bin/ba

fail_with() {
    echo -e "Error: $1"
    exit 1
}

debug() {
    echo -e $1
}

get_os() {
    os=""

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        os="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os="darwin"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        os="windows"
    elif [[ "$OSTYPE" == "msys" ]]; then
        os="windows"
    else
        fail_with "Unsupported OS: $OSTYPE"
    fi

    echo $os
}

get_version() {
    curl -s https://get.bytearena.com/version
}

download_url() {
    curl -L --progress-bar "$1" -o "$2"

    if [[ $? -ne 0 ]]; then
        fail_with "Could not download release"
    fi
}

install_bin() {
    debug "\n[2/3] Installing binary in $TARGET"

    if [ ! -w "/usr/local/bin" ] ; then
        sudo=sudo
        debug "Sudo required!"
    fi

    if [ ! -e "/usr/local/bin" ] ; then
        debug "/usr/local/bin does not exist; it's gonna be created"
        if [ -w "/usr/local" ] ; then
        mkdir -p "/usr/local/bin"
        else
        $sudo mkdir -p "/usr/local/bin"
        fi
    fi

    $sudo mv $1 $TARGET; $sudo chmod +x $TARGET

    if [[ $? -ne 0 ]]; then
        fail_with "Failed to install Byte Arena CLI\n"
    else
        debug "Installation completed; the command 'ba' should now be available\n"
    fi
}

update_maps() {
  $TARGET map update
}

run() {
    mkdir -p  ~/.bytearena/maps
    touch ~/.bytearena/maps/hexagon.zip

    os=$(get_os)
    tag=$(get_version)

    debug "[1/3] Downloading version: $tag"

    bin_name="ba-$tag-amd64-$os"
    url="https://github.com/ByteArena/cli/releases/download/$tag/$bin_name"

    bin=$(mktemp)

    download_url "$url" "$bin"
    install_bin "$bin"

    debug "[3/3] Updating maps"

    update_maps

    debug "[OK] Bytearena cli was successfully installed"

    exit 0
}

run
