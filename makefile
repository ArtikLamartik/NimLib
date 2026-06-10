.PHONY: default build clean install unsintall

default:
	@echo "Usage: make [build|clean|install|uninstall]"

build:
	@echo "[Building]"
	@nim c --app:lib --out:build/nimlib.so src/main.nim

clean:
	@echo "[Cleaning]"
	@rm -f build/nimlib.so

install:
	@echo "[Installing]"
	@sudo cp build/nimlib.so /usr/lib32/
	@sudo ldconfig

uninstall:
	@echo "[Uninstalling]"
	@sudo rm -f /usr/lib32/nimlib.so
