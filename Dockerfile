FROM alpine:3.10
MAINTAINER Victor Trac <victor@cloudkite.io>

ENV VERSION="1.30.3116.68"

# Build deps
RUN apk --no-cache add --update go git bzr wget py2-pip \ 
    gcc python python-dev make musl-dev linux-headers libffi-dev openssl-dev \
    py-setuptools openssl procps ca-certificates openvpn 
    
RUN pip install --upgrade pip 

# Pritunl Install
RUN export GOPATH=/go \
    && go get github.com/pritunl/pritunl-dns \
    && go get github.com/pritunl/pritunl-web \
    && cp /go/bin/* /usr/bin/ 

RUN https://github.com/pritunl/pritunl/archive/refs/tags/${VERSION}.tar.gz \
    && tar zxvf ${VERSION}.tar.gz \
    && cd pritunl-${VERSION} \
    && python setup.py build \
    && pip install -r requirements.txt \
    && python2 setup.py install \
    && cd .. \
    && rm -rf *${VERSION}* \
    && rm -rf /tmp/* /var/cache/apk/*

RUN sed -i -e '/^attributes/a prompt\t\t\t= yes' /etc/ssl/openssl.cnf
RUN sed -i -e '/countryName_max/a countryName_value\t\t= US' /etc/ssl/openssl.cnf

ADD rootfs /

EXPOSE 80
EXPOSE 443
EXPOSE 1194
EXPOSE 2032
EXPOSE 9731
ENTRYPOINT ["/init"]
