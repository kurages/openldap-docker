#!/usr/local/bin/ash

readonly CONF_FILE=/usr/local/etc/openldap/slapd.conf
readonly CONF_DIR=/usr/local/etc/openldap/slapd.d
readonly DATA_DIR=/usr/local/var/openldap-data

mkdir -p $CONF_DIR $DATA_DIR

if [ "$INIT" = "true" ]; then
	slaptest -d 1 -f $CONF_FILE -F $CONF_DIR
	exit $?
fi

exec /usr/local/libexec/slapd "$@" -h "ldap:/// ldapi:///"
