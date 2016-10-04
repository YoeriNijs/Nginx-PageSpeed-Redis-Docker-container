FROM debian:jessie

MAINTAINER Itris <yoeri.nijs@itris.nl>

ENV NPS_VERSION 1.11.33.4
ENV REDIS_VERSION 0.3.8

WORKDIR /tmp

RUN apt-get update && \
    apt-get install -y linux-kernel-headers wget ca-certificates build-essential gzip libpcre3 libpcre3-dev libssl-dev openssl libgd2-xpm-dev libgeoip-dev libperl-dev libxslt1-dev lsb-release zlib1g-dev  unzip debhelper gcc mono-mcs
 
RUN wget http://nginx.org/download/nginx-1.11.4.tar.gz -O nginx.tar.gz && \
    mkdir /tmp/nginx && \
    tar -xzvf nginx.tar.gz -C /tmp/nginx --strip-components=1 && \
    wget http://people.freebsd.org/~osa/ngx_http_redis-${REDIS_VERSION}.tar.gz && \       
    tar -xzvf ngx_http_redis-${REDIS_VERSION}.tar.gz -C nginx/src/http/modules/ 

RUN wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip && \
    unzip release-${NPS_VERSION}-beta.zip && \
    cd ngx_pagespeed-release-${NPS_VERSION}-beta/ && \
    wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
    tar -xzvf ${NPS_VERSION}.tar.gz

WORKDIR /tmp/nginx

RUN ./configure \
        --with-debug \
        --prefix=/usr/share/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --pid-path=/run/nginx.pid \
        --lock-path=/run/lock/subsys/nginx \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
        --with-http_ssl_module \
        --with-pcre \
        --with-http_image_filter_module \
        --with-file-aio \
        --with-ipv6 \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --add-module=/tmp/nginx/src/http/modules/ngx_http_redis-${REDIS_VERSION} \
        --add-module=/tmp/ngx_pagespeed-release-${NPS_VERSION}-beta && \
    make && \
    make install

COPY nginx.conf /etc/nginx/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
