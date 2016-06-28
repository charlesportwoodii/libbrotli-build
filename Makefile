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
	make -j$(CORES)

fpm_debian:
	echo "Packaging libbrotli for Debian"

	cd /tmp/libbrotli && make install DESTDIR=/tmp/libbrotli-install

	fpm -s dir \
		-t deb \
		-n libbrotli \
		-v $(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/libbrotli-install \
		-p libbrotli_$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/librotli-build \
		--description "libbrotli" \
		--deb-systemd-restart-after-upgrade

fpm_rpm:
	echo "Packaging libbrotli for RPM"

	cd /tmp/libbrotli && make install DESTDIR=/tmp/libbrotli-install

	fpm -s dir \
		-t rpm \
		-n libbrotli \
		-v $(RELEASEVER) \
		-C /tmp/libbrotli-install \
		-p libbrotli_$(RELEASEVER)_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/libbrotli-build \
		--description "libbrotli" \
		--vendor "Charles R. Portwood II" \
		--rpm-digest sha384 \
		--rpm-compression gzip
