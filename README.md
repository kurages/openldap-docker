
docker run -it --rm --entrypoint=slappasswd openldap
docker cp $(docker run -d -it --rm --entrypoint=sleep openldap 10):/usr/local/etc/openldap/slapd.conf .


