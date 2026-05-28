#!/bin/bash

build() {
    echo "[Building]"
    nim c --app:lib --out:build/nimlib.so src/main.nim
}

install() {
    echo "[Installing]"
    sudo cp build/nimlib.so /usr/lib32/
    sudo ldconfig
}

if [ $# -eq 0 ]; then
    echo "Usage: bash build.sh [--build|-b] [--install|-i]"
    exit 0
fi

for arg in "$@"; do
    case "$arg" in
        --build|-b) build ;;
        --install|-i) install ;;
        *) echo "Unknown argument: $arg" ;;
    esac
done
