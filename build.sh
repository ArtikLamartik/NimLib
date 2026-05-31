build() {
    echo "[Building]"
    nim c --app:lib --out:build/nimlib.so src/main.nim
}

clean() {
    echo "[Cleaning]"
    rm -f build/nimlib.so
}

install() {
    echo "[Installing]"
    sudo cp build/nimlib.so /usr/lib32/
    sudo ldconfig
}

uninstall() {
    echo "[Uninstalling]"
    sudo rm -f /usr/lib32/nimlib.so
}

if [ $# -eq 0 ]; then
    echo "Usage: bash build.sh [--build|-b] [--clean|-c] [--install|-i] [--uninstall|-u]"
    exit 0
fi

for arg in "$@"; do
    case "$arg" in
        --build|-b) build ;;
        --clean|-c) clean ;;
        --install|-i) install ;;
        --uninstall|-u) uninstall ;;
        *) echo "Unknown argument: $arg" ;;
    esac
done
