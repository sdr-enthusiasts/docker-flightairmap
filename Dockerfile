FROM debian:stable-slim

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    MYSQLUSERNAME=flightairmap \
    MYSQLDATABASE=flightairmap \
    WEBUSER=flightairmap \
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

RUN set -x && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        pwgen \
        curl \
        wget \
        ca-certificates \
        jq \
        html2text \
        socat \
        git \
        locales && \
    useradd -d /home/${WEBUSER} -m -r -U ${WEBUSER} && \
    echo "========== Deploy php7 ==========" && \
    apt-get install -y --no-install-recommends \
        php \
        php-curl \
        php-mysql \
        php-json \
        php-zip \
        php-xml \
        php-gettext \
        php-fpm \
        php-gd && \
    sed -i '/;error_log/c\error_log = /proc/self/fd/2' /etc/php/7.3/fpm/php-fpm.conf && \
    mkdir -p /run/php && \
    rm -vrf /etc/php/7.3/fpm/pool.d/* && \
    echo "========== Deploy nginx ==========" && \
    apt-get install -y --no-install-recommends \
        nginx-light && \
    rm -vf /etc/nginx/conf.d/default.conf && \
    rm -vrf /var/www/localhost && \
    usermod -aG www-data ${WEBUSER} && \
    echo "========== Deploy MariaDB ==========" && \
    apt-get install -y --no-install-recommends \
        mariadb-server && \
    mkdir -p /run/mysqld && \
    chown -vR mysql:mysql /run/mysqld && \
    echo "========== Deploy FlightAirMap ==========" && \
    git clone --recursive https://github.com/Ysurac/FlightAirMap /var/www/flightairmap/htdocs && \
    cd /var/www/flightairmap/htdocs && \
    cp -v /var/www/flightairmap/htdocs/install/flightairmap-nginx-conf.include /etc/nginx/flightairmap-nginx-conf.include && \
    chown -vR ${WEBUSER}:${WEBUSER} /var/www/flightairmap && \
    git log | head -1 | tr -s " " "_" | tee /VERSION && \
    echo "========== Deploy s6-overlay ==========" && \
    wget -q -O - https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    echo "========== Clean up ==========" && \
    rm -rf /var/lib/apt/lists/* /tmp/* /src

# TEMP FOR DEBUGGING
RUN apt-get update && apt-get install -y procps net-tools less vim

# Copy config files
COPY etc/ /etc/

ENTRYPOINT [ "/init" ]

EXPOSE 80

