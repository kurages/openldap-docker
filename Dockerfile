FROM ubuntu

RUN apt update -y \
	&& apt install -y wget make gcc groff-base libssl-dev

RUN wget -O - https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.5.19.tgz | tar -xzvf - -C /tmp/

RUN cd /tmp/openldap-2.5.19 \
	&& ./configure --prefix=/usr/local \
	&& make depend \
	&& make \
	&& echo make test \
	&& make install

