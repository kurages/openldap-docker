#!/bin/sh

if [ "$1" = "--" ]; then
	exec "$@"
	exit $?
fi

readonly CONF_FILE=/usr/local/etc/openldap/slapd.conf
readonly CONF_DIR=/usr/local/etc/openldap/slapd.d
readonly DATA_DIR=/usr/local/var/openldap-data

mkdir -p $CONF_DIR $DATA_DIR

if [ "$EXEC_USER" = "" ]; then
	EXEC_USER=`id -u`
fi

if [ "$EXEC_GROUP" = "" ]; then
	EXEC_GROUP=`id -g`
fi

if [ "$INIT" = "true" ]; then
	slaptest -d 1 -d 16 -f $CONF_FILE -F $CONF_DIR
	exit $?
fi

if [ "$DEBUG_LEVEL" = "" ]; then
	DEBUG_LEVEL=64
fi

exec /usr/local/libexec/slapd -u $EXEC_USER -g $EXEC_GROUP -d $DEBUG_LEVEL "$@"
