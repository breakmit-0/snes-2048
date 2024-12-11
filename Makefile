#rebuild all assets and compile

main:
	$(MAKE) -C ./assets
	asar --verbose --symbols=wla ./game.asm
