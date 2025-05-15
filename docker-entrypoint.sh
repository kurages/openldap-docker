#!/usr/local/bin/busybox ash

if [ ! -d /usr/local/var/openldap-data ]; then
	/usr/local/sbin/slapadd -n 0 -F /usr/local/etc/slapd.d -l /usr/local/etc/openldap/slapd.ldif
	mkdir -p /usr/local/var/openldap-data
fi

exec /usr/local/libexec/slapd "$@"

