#!/bin/bash

build() {
    nim c --app:lib --out:build/nimlib.so src/main.nim
}

install() {
    sudo cp build/nimlib.so /usr/lib32/
    sudo ldconfig
    echo "Installed."
}

for arg in "$@"; do
    case "$arg" in
        --build|-b) build ;;
        --install|-i) install ;;
        *) echo "Unknown argument: $arg" ;;
    esac
done
