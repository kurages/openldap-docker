FROM debian:12.10-slim AS builder

RUN apt update -y \
	&& apt-get install -y wget build-essential groff-base pkg-config \
		libltdl-dev \
		libwrap0-dev \
		libevent-dev \
		libssl-dev \
		libwiredtiger-dev \
		libsasl2-dev \
		libargon2-dev

RUN wget -O - http://sourceforge.net/projects/openslp/files/2.0.0/2.0.0%20Release/openslp-2.0.0.tar.gz/download | tar -xzvf - -C /tmp/
RUN cd /tmp/openslp-2.0.0 \
	&& ./configure \
	&& make \
	&& make install

ARG OPENLDAP_VERSOIN=2.5.19
RUN wget -O - https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSOIN}.tgz | tar -xzvf - -C /tmp/

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
			CPPFLAGS="-I/usr/local/include/sasl -I/usr/local/include" \
			LDFLAGS="-L/usr/local/lib/sasl" \
	&& make depend \
	&& make -j4 \
	&& echo make test \
	&& make install

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

FROM debian:12.10-slim

RUN apt update -y \
	&& apt-get install -y \
		libltdl7 \
		libwrap0 \
		libssl3 \
		libsasl2-2 \
		libwiredtiger0 \
		libargon2-1

ENV LD_LIBRARY_PATH=/usr/local/lib
COPY --from=builder /usr/local /usr/local

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["-F", "/usr/local/etc/openldap/slapd.d", "-h", "ldap:/// ldapi:///"]
