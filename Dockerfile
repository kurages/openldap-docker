FROM ubuntu

RUN apt update -y && apt install -y curl
WORKDIR /tmp
RUN curl -O https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.5.19.tgz \
	&& tar -xvf openldap-2.5.19.tgz

RUN apt install -y gcc
RUN apt install -y libssl-dev
RUN apt install make
RUN apt install -y groff-base
WORKDIR /tmp/openldap-2.5.19
RUN ./configure --prefix=/usr/local
RUN make depend \
	&& make \
	&& make test \
	&& make install


