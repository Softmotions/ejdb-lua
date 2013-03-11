CFLAGS=-g -O0 -fPIC -std=c99 -Wall

build:
	luarocks --pack-binary-rock CFLAGS='$(CFLAGS)' make

test: build
	make -C ./test

clean:
	rm -rf *.so *.rock
	make -C ./test clean


.PHONY: build test clean