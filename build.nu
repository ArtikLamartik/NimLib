def main [
    --build (-b)
    --clean (-c)
    --install (-i)
    --uninstall (-u)
] {
    if $build {
        print "[Building]"
        nim c --app:lib --out:./build/nimlib.so ./src/main.nim
    }
    if $clean {
        print "[Cleaning]"
        rm -f ./build/nimlib.so
    }
    if $install {
        print "[Installing]"
        sudo cp ./build/nimlib.so /usr/lib32/
        sudo ldconfig
    }
    if $uninstall {
        print "[Uninstalling]"
        sudo rm -f /usr/lib32/nimlib.so
    }
    if not ($build or $clean or $install or $uninstall) {
        print "Usage: nu build.nu [--build|-b] [--clean|-c] [--install|-i] [--uninstall|-u]"
    }
}
