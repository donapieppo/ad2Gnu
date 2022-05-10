FROM debian:bullseye
MAINTAINER Donapieppo <donapieppo@yahoo.it>

ENV DEBIAN_FRONTEND noninteractive
ENV LDAP_OPENLDAP_UID 1000
ENV LDAP_OPENLDAP_GID 1000

RUN apt-get update \
    && apt-get install -y -y --no-install-recommends git apt-transport-https vim \
               krb5-config krb5-user \
               ruby ruby-ldap thin \
               libldap2-dev libsasl2-modules-gssapi-mit libsasl2-dev ruby-ldap libruby ruby-dev \
               ldap-utils 

WORKDIR /app
COPY . .
COPY ./doc/docker_ad2gnu.yml /etc/ad2gnu.yml
COPY ./doc/docker_ldap.conf /etc/ldap/ldap.conf

RUN gem build ad2gnu.gemspec
RUN gem install ad2gnu

CMD ["/bin/bash"]

# gem build ad2gnu.gemspec 
# gem install ad2gnu




