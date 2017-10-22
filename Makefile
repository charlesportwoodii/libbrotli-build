SHELL := /bin/bash

VERSION?=1.0.1
RELEASEVER?=1
SCRIPTPATH=$(shell pwd -P)

build: clean libbrotli pre_package

clean:
	rm -rf /tmp/brotli

libbrotli:
	mkdir -p /tmp
	rm -rf /tmp/brotli

	# Download and install brotli
	cd /tmp && \
	git clone https://github.com/google/brotli --recursive -b v$(VERSION) && \
	cd /tmp/brotli && \
	mkdir -p out && \
	cd out && \
	../configure-cmake --disable-debug && \
	make && \
	make test

pre_package:
	cd /tmp/brotli/out && make install DESTDIR=/tmp/brotli-install

	mkdir -p /tmp/brotli-install/etc/ld.so.conf.d/
	echo "/usr/local/lib/" > /tmp/brotli-install/etc/ld.so.conf.d/brotli.conf

fpm_debian:
	fpm -s dir \
		-t deb \
		-n libbrotli \
		-v $(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/brotli-install \
		-p libbrotli_$(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/librotli-build \
		--description "brotli (https://github.com/google/brotli)" \
		--force \
		--deb-systemd-restart-after-upgrade

fpm_rpm:
	fpm -s dir \
		-t rpm \
		-n libbrotli \
		-v $(VERSION)_$(RELEASEVER) \
		-C /tmp/brotli-install \
		-p libbrotli_$(VERSION)-$(RELEASEVER)_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/brotli-build \
		--description "brotli (https://github.com/google/brotli)"
		--vendor "Charles R. Portwood II" \
		--force \
		--rpm-digest sha384 \
		--rpm-compression gzip

fpm_alpine:
	fpm -s dir \
		-t apk \
		-n libbrotli \
		-v $(VERSION)-$(RELEASEVER)~$(shell uname -m) \
		-C /tmp/brotli-install \
		-p libbrotli-$(VERSION)-$(RELEASEVER)~$(shell uname -m).apk \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/librotli-build \
		--description "brotli (https://github.com/google/brotli)" \
		-a $(shell uname -m) \
		--force
