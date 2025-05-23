
## How to use
### setup
```sh
docker compose build --progress=plain
docker run -it --rm --entrypoint=slappasswd ldap-ldap
docker cp $(docker run -d -it --rm --entrypoint=sleep ldap-ldap 10):/usr/local/etc/openldap/slapd.conf .
INIT=true docker compose up ldap
```

### exeute

```sh
docker compose up -d
docker compose exec -it ldap ldapadd -f /ldif/example.ldif -x -D "cn=Manager,dc=example,dc=com" -W
```

### debug

```sh
# build stage
docker run -it --rm $(docker build -q --target builder-openldap .)
# artifact stage
docker run -it --rm --entrypoint=ash  $(docker build -q .)
```

