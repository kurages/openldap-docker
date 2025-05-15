FROM debian AS builder

RUN apt update -y \
	&& apt install -y wget build-essential make gcc groff-base

RUN wget -O - https://github.com/openssl/openssl/releases/download/openssl-3.5.0/openssl-3.5.0.tar.gz | tar -xzvf - -C /tmp/ 
RUN cd /tmp/openssl-3.5.0 \
	&& ./Configure --prefix=/opt/openssl \
	&& make -j4 \
	&& make install_sw

RUN wget -O - https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.5.19.tgz | tar -xzvf - -C /tmp/
RUN cd /tmp/openldap-2.5.19 \
	&& ./configure --prefix=/usr/local --enable-ldap \
		CPPFLAGS="-I/opt/openssl/include" \
                LDFLAGS="-L/opt/openssl/lib -Wl,-rpath,/opt/openssl/lib" \
	&& make depend \
	&& make -j4 \
	&& echo make test \
	&& make install

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY --from=busybox /bin/busybox /usr/local/bin/busybox
RUN cd /usr/local/bin && /usr/local/bin/busybox --install -s /usr/local/bin

# -----------------------------------------------------------------------------
FROM gcr.io/distroless/base-debian12
COPY --from=builder /usr/local /usr/local
SHELL ["/usr/local/bin/busybox", "ash", "-c"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh", "-d", "16", "-u", "0", "-g", "0"]
CMD ["-F", "/usr/local/etc/openldap/slapd.d"]

