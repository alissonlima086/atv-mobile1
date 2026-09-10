.PHONY: run build clean get doctor apk install-apk

PORT ?= 8080

##instalar/atualizar dependencias do pubsec
get:
	flutter pub get

## subir app no navegador via webserver
run: get
	flutter run -d web-server --web-port=$(PORT) --web-hostname=0.0.0.0

##gerar build apk
apk: get
	flutter build apk --release

## instalar apk via adb com usb debg
install-apk: apk
	adb install -r build/app/outputs/flutter-apk/app-release.apk

## gerar build web
build: get
	flutter build web

## limpar build e cache
clean:
	flutter clean

## checar o setup do flutter
doctor:
	flutter doctor -v
