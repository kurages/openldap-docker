#!/bin/sh

if [ "$1" = "--" ]; then
	exec "$@"
	exit $?
elif [ "$1" = "-T" ]; then
	# tool mode
	exec /usr/local/libexec/slapd "$@"
	exit $?
fi

if [ "$EXEC_USER" = "" ]; then
	EXEC_USER=`id -u`
fi

if [ "$EXEC_GROUP" = "" ]; then
	EXEC_GROUP=`id -g`
fi

if [ "$CONF_FILE" = "" ]; then
	CONF_FILE="/usr/local/etc/openldap/slapd.conf"
fi

if [ "$CONF_DIR" = "" ]; then
	CONF_DIR="/usr/local/etc/openldap/slapd.d"
fi

if [ "$DATA_DIR" = "" ]; then
	DATA_DIR="/usr/local/var/openldap-data"
fi

if [ "$DEBUG_LEVEL" = "" ]; then
	DEBUG_LEVEL=64
fi

if [ "$URL_LIST" = "" ]; then
	URL_LIST="ldap:/// ldapi:///"
fi

mkdir -p $CONF_DIR $DATA_DIR
if [ "$INIT" = "true" ]; then
	slaptest -d 1 -d 16 -f $CONF_FILE -F $CONF_DIR
	exit $?
fi

exec /usr/local/libexec/slapd \
	-d $DEBUG_LEVEL \
	-u $EXEC_USER -g $EXEC_GROUP \
	-F $CONF_DIR \
	-h $URL_LIST \
	"$@"
