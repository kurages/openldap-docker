# FROM scratch AS empty
# RUN mkdir -p /usr/local

# -----------------------------------------------------------------------------
# builder base image
# -----------------------------------------------------------------------------
FROM debian:12.10-slim AS builder-base

RUN apt update -y && apt-get install -y wget build-essential

# -----------------------------------------------------------------------------
# OpenSSL
# -----------------------------------------------------------------------------
# FROM builder-base AS builder-openssl
# RUN wget -O - https://github.com/openssl/openssl/releases/download/openssl-3.5.0/openssl-3.5.0.tar.gz | tar -xzvf - -C /tmp/ 
# RUN cd /tmp/openssl-3.5.0 \
# 	&& ./Configure --prefix=/usr/local \
# 	&& make -j4 \
# 	&& make install_sw

# -----------------------------------------------------------------------------
# OpenSLP
# -----------------------------------------------------------------------------
FROM builder-base AS builder-openslp

RUN wget -O - http://sourceforge.net/projects/openslp/files/2.0.0/2.0.0%20Release/openslp-2.0.0.tar.gz/download | tar -xzvf - -C /tmp/
RUN cd /tmp/openslp-2.0.0 \
	&& ./configure \
	&& make \
	&& make install

# -----------------------------------------------------------------------------
# Cyrus SASL
# -----------------------------------------------------------------------------
FROM builder-base AS builder-cyrus-sasl
ARG CYRUS_SASL_VERSOIN=2.1.28

RUN wget -O - https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-${CYRUS_SASL_VERSOIN}/cyrus-sasl-${CYRUS_SASL_VERSOIN}.tar.gz | tar -xzvf - -C /tmp/
RUN cd /tmp/cyrus-sasl-${CYRUS_SASL_VERSOIN} \
	&& ./configure \
	&& make \
	&& make install

	
# -----------------------------------------------------------------------------
# wiredtiger
# -----------------------------------------------------------------------------
FROM builder-base AS builder-wiredtiger
ARG WIREDTIGER_VERSION=11.3.1
RUN wget -O - https://github.com/wiredtiger/wiredtiger/archive/refs/tags/${WIREDTIGER_VERSION}.tar.gz | tar -xzvf - -C /tmp/
RUN wget -O - https://sourceforge.net/projects/swig/files/swig/swig-3.0.12/swig-3.0.12.tar.gz/download | tar -xzvf - -C /tmp/

RUN cd /tmp/swig-3.0.12 \
	&& wget "https://nchc.dl.sourceforge.net/project/pcre/pcre/8.45/pcre-8.45.tar.bz2" \
	&& ./Tools/pcre-build.sh \
	&& ./configure \
	&& make \
	&& make install

RUN mkdir /tmp/wiredtiger-${WIREDTIGER_VERSION}/build\
	cd /tmp/wiredtiger-${WIREDTIGER_VERSION}/build \
	&& apt-get install -y cmake python3 python3-dev \
	&& mkdir build && cd build \
	&& make -j4 \
	&& make install

# -----------------------------------------------------------------------------
# OpenLdap
# -----------------------------------------------------------------------------
FROM builder-base AS builder-openldap
ARG OPENLDAP_VERSOIN=2.5.19

RUN apt-get install -y groff-base libltdl-dev libwrap0-dev pkg-config libevent-dev libssl-dev libargon2-dev
RUN wget -O - https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSOIN}.tgz | tar -xzvf - -C /tmp/

COPY --from=builder-openslp /usr/local /usr/local
COPY --from=builder-cyrus-sasl /usr/local /usr/local
COPY --from=builder-wiredtiger /usr/local /usr/local

RUN cd /tmp/openldap-${OPENLDAP_VERSOIN} \
	&& ./configure --prefix=/usr/local \
		--enable-slapd \
		--enable-dynacl \
		--enable-aci \
		--enable-cleartext \
		--enable-crypt \
		--enable-spasswd \
		--enable-modules \
		--enable-rlookups \
		--enable-slapi \
		--enable-wrappers \
		--enable-backends \
		--enable-overlays --with-tls=openssl \
		--enable-argon2 --with-argon2=libargon2 \
		--enable-balancer \
		--enable-versioning \
		--enable-static \
			CPPFLAGS="-I/usr/local/include" \
			LDFLAGS="-static -L/usr/local/lib -Wl,-rpath,/usr/local/lib" \
	&& make depend \
	&& make -j4 \
	&& echo make test \
	&& make install

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY --from=busybox /bin/busybox /usr/local/bin/busybox
RUN cd /usr/local/bin && /usr/local/bin/busybox --install -s /usr/local/bin

# -----------------------------------------------------------------------------
# artifact
# -----------------------------------------------------------------------------
FROM gcr.io/distroless/base-debian12
COPY --from=builder-openldap /usr/local /usr/local
SHELL ["/usr/local/bin/busybox", "ash", "-c"]

ENV LD_LIBRARY_PATH=/usr/local/lib

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh", "-d", "16", "-u", "0", "-g", "0"]
CMD ["-F", "/usr/local/etc/openldap/slapd.d"]

