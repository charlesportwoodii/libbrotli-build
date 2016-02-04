SHELL := /bin/bash


RELEASEVER?=1
RELEASE=$(shell lsb_release --codename | cut -f2)
SCRIPTPATH=$(shell pwd -P)

build: clean libbrotli

clean:
	rm -rf /tmp/libbrotli

libbrotli:
	mkdir -p /tmp
	rm -rf /tmp/libbrotli

	# Download and install libbrotli
	cd /tmp && \
	git clone https://github.com/bagder/libbrotli && \
	cd /tmp/libbrotli && \
	./autogen.sh && \
	./configure && \
	make -j$(CORES) && \
	make install

package:
	# Copy Packaging tools
	cp -R $(SCRIPTPATH)/*-pak /tmp/libbrotli

	cd /tmp/libbrotli && \
	checkinstall \
		-D \
		--fstrans \
		-pkgname libbrotli \
		-pkgrelease "$(RELEASEVER)"~"$(RELEASE)" \
		-pkglicense MIT \
		-pkggroup lua \
		-maintainer charlesportwoodii@ethreal.net \
		-provides "libbrotli" \
		-pakdir /tmp \
		-y
