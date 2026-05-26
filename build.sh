#!/bin/bash

build() {
    echo "Building."
    nim c --app:lib --out:build/nimlib.so src/main.nim
}

install() {
    echo "Installing."
    sudo cp build/nimlib.so /usr/lib32/
    sudo ldconfig
}

for arg in "$@"; do
    case "$arg" in
        --build|-b) build ;;
        --install|-i) install ;;
        *) echo "Unknown argument: $arg" ;;
    esac
done
