def main [
    --build (-b)
    --install (-i)
] {
    if $build {
        print "[Building]"
        nim c --app:lib --out:build/nimlib.so src/main.nim
    }
    if $install {
        print "[Installing]"
        sudo cp build/nimlib.so /usr/lib32/
        sudo ldconfig
    }
    if not ($build or $install) {
        print "Usage: nu build.nu [--build|-b] [--install|-i]"
    }
}
