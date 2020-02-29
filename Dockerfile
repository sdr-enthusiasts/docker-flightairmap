FROM alpine:3.11

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    PGDATA=/var/lib/postgresql/flightairmap \
    PGUSERNAME=flightairmap \
    PGDATABASE=flightairmap \
    TZ=UTC \
    FAM_GLOBALSITENAME="My FlightAirMap Site" \
    FAM_LANGUAGE="EN" \
    FAM_MAPPROVIDER="OpenStreetMap" \
    FAM_MAPBOXID="examples.map-i86nkdio" \
    FAM_MAPBOXTOKEN="" \
    FAM_GOOGLEKEY="" \
    FAM_BINGKEY="" \
    FAM_MAPQUESTKEY="" \
    FAM_HEREAPPID="" \
    FAM_HEREAPPCODE="" \
    FAM_OPENWEATHERMAPKEY="" \
    FAM_LATITUDEMAX="46.92" \
    FAM_LATITUDEMIN="42.14" \
    FAM_LONGITUDEMAX="6.2" \
    FAM_LONGITUDEMIN="1.0" \
    FAM_LATITUDECENTER="46.38" \
    FAM_LONGITUDECENTER="5.29" \
    FAM_LIVEZOOM="9" \
    FAM_SQUAWK_COUNTRY="EU" \
    FAM_SAILAWAYEMAIL="" \
    FAM_SAILAWAYPASSWORD="" \
    FAM_SAILAWAYKEY="" \
    FAM_BRITISHAIRWAYSAPIKEY="" \
    FAM_CORSPROXY="https://galvanize-cors-proxy.herokuapp.com/" \
    FAM_LUFTHANSAKEY="" \
    FAM_LUFTHANSASECRET="" \
    FAM_FLIGHTAWAREUSERNAME="" \
    FAM_FLIGHTAWAREPASSWORD="" \
    FAM_MAPMATCHINGSOURCE="fam" \
    FAM_GRAPHHOPPERAPIKEY="" \
    FAM_NOTAMSOURCE="" \
    FAM_METARSOURCE="" \
    FAM_BITLYACCESSTOKENAPI="" \
    FAM_GEOID_SOURCE="egm96-15" \
    BASESTATIONPORT="30003"

RUN apk update && \
    apk add \
        bash \
        pwgen \
        shadow \
        sed \
        curl \
        grep \
        jq \
        html2text \
        socat \
        git && \
    useradd -d /home/${PGUSERNAME} -m -r -U ${PGUSERNAME} && \
    echo "========== Deploy php7 ==========" && \
    apk add \
        php7 \
        php7-curl \
        php7-pgsql \
        php7-pdo_pgsql \
        php7-json \
        php7-zip \
        php7-dom \
        php7-xml \
        php7-session \
        php7-gettext \
        php7-sockets \
        php7-ctype \
        php7-fpm \
        php7-gd && \
    sed -i '/;error_log/c\error_log = /proc/self/fd/2' /etc/php7/php-fpm.conf && \
    rm -vrf /etc/php7/php-fpm.d/* && \
    echo "========== Deploy nginx ==========" && \
    apk add \
        nginx && \
    rm -vf /etc/nginx/conf.d/default.conf && \
    rm -vrf /var/www/localhost && \
    usermod -aG nginx ${PGUSERNAME} && \
    echo "========== Deploy PostgreSQL ==========" && \
    apk add \
        postgresql && \
    mkdir -p /run/postgresql && \
    chown -vR ${PGUSERNAME}:${PGUSERNAME} /run/postgresql && \
    mkdir -p ${PGDATA} && \
    chown -vR ${PGUSERNAME}:${PGUSERNAME} ${PGDATA} && \
    usermod -aG postgres ${PGUSERNAME} && \
    echo "========== Build postgis ==========" && \
    apk add \
        gcc \
        make \
        cmake \
        musl-dev \
        autoconf \
        automake \
        libtool \
        postgresql-dev \
        libxml2-dev \
        geos-dev \
        g++ \
        sqlite-dev \
        sqlite \
        json-c-dev && \
    mkdir -p /src && \
    cd /src && \
    echo "Building proj (prereq for postgis)..." && \
    wget https://download.osgeo.org/proj/proj-6.3.1.tar.gz && \
    tar xzvf proj-6.3.1.tar.gz && \
    cd proj-6.3.1 && \
    ./configure && \
    make && \
    make install && \
    cd /src && \
    echo "Building postgis..." && \
    git clone -b stable-3.0 https://git.osgeo.org/gitea/postgis/postgis.git postgis-3.0 && \
    cd /src/postgis-3.0 && \
    ./autogen.sh && \
    ./configure --without-raster && \
    make && \
    make install && \
    echo "========== Deploy FlightAirMap ==========" && \
    git clone --recursive https://github.com/Ysurac/FlightAirMap /var/www/flightairmap/htdocs && \
    cp -v /var/www/flightairmap/htdocs/install/flightairmap-nginx-conf.include /etc/nginx/flightairmap-nginx-conf.include && \
    chown -vR ${PGUSERNAME}:${PGUSERNAME} /var/www/flightairmap && \
    echo "========== Deploy s6-overlay ==========" && \
    wget -q -O - https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    echo "========== Clean up ==========" && \
    apk del \
        git \
        gcc \
        make \
        cmake \
        musl-dev \
        autoconf \
        automake \
        binutils \
        g++ \
        libc-dev \
        libxml2-dev \
        openssl-dev \
        postgresql-dev \
        sqlite-dev \
        xz-dev \
        zlib-dev && \
    rm -rf /var/cache/apk/* /src

# Copy config files
COPY etc/ /etc/

ENTRYPOINT [ "/init" ]

EXPOSE 80

