FROM ghcr.io/sdr-enthusiasts/docker-baseimage:base

ENV BASESTATIONPORT="30003" \
    FAM_BINGKEY="" \
    FAM_BITLYACCESSTOKENAPI="" \
    FAM_BRITISHAIRWAYSAPIKEY="" \
    FAM_CORSPROXY="https://galvanize-cors-proxy.herokuapp.com/" \
    FAM_FLIGHTAWAREPASSWORD="" \
    FAM_FLIGHTAWAREUSERNAME="" \
    FAM_GEOID_SOURCE="egm96-15" \
    FAM_GLOBALSITENAME="My FlightAirMap Site" \
    FAM_GOOGLEKEY="" \
    FAM_GRAPHHOPPERAPIKEY="" \
    FAM_HEREAPPCODE="" \
    FAM_HEREAPPID="" \
    FAM_LANGUAGE="EN" \
    FAM_LATITUDECENTER="46.38" \
    FAM_LATITUDEMAX="46.92" \
    FAM_LATITUDEMIN="42.14" \
    FAM_LIVEZOOM="9" \
    FAM_LONGITUDECENTER="5.29" \
    FAM_LONGITUDEMAX="6.2" \
    FAM_LONGITUDEMIN="1.0" \
    FAM_LUFTHANSAKEY="" \
    FAM_LUFTHANSASECRET="" \
    FAM_MAPBOXID="examples.map-i86nkdio" \
    FAM_MAPBOXTOKEN="" \
    FAM_MAPMATCHINGSOURCE="fam" \
    FAM_MAPPROVIDER="OpenStreetMap" \
    FAM_MAPQUESTKEY="" \
    FAM_METARSOURCE="" \
    FAM_NOTAMSOURCE="" \
    FAM_OPENWEATHERMAPKEY="" \
    FAM_SAILAWAYEMAIL="" \
    FAM_SAILAWAYKEY="" \
    FAM_SAILAWAYPASSWORD="" \
    FAM_SQUAWK_COUNTRY="EU" \
    MYSQLDATABASE=flightairmap \
    MYSQLUSERNAME=flightairmap \
    MYSQLPORT=3306 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    TZ=UTC \
    WEBUSER=flightairmap \
    QUIET_FAM=true

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,SC2086,SC2039,SC2068
RUN set -x && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    file \
    git \
    html2text \
    jq \
    locales \
    procps \
    socat \
    wget \
    pwgen \
    && \
    useradd -d "/home/${WEBUSER}" -m -r -U "${WEBUSER}" && \
    echo "========== Setup locales ==========" && \
    echo "en_US ISO-8859-1" >> /etc/locale.gen && \
    echo "de_DE ISO-8859-1" >> /etc/locale.gen && \
    echo "es_ES ISO-8859-1" >> /etc/locale.gen && \
    echo "fr_FR ISO-8859-1" >> /etc/locale.gen && \
    locale-gen && \
    echo "========== Deploy php ==========" && \
    apt-get install software-properties-common ca-certificates lsb-release apt-transport-https gpg-agent -y --no-install-recommends && \
    sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
    wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add - && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    php7.4 \
    php7.4-curl \
    php7.4-fpm \
    php7.4-gd \
    php7.4-gettext \
    php7.4-json \
    php7.4-mysql \
    php7.4-xml \
    php7.4-zip \
    && \
    sed -i '/;error_log/c\error_log = /proc/self/fd/2' /etc/php/7.4/fpm/php-fpm.conf && \
    mkdir -p /run/php && \
    #rm -vrf /etc/php/8.2/fpm/pool.d/* && \
    echo "========== Deploy nginx ==========" && \
    apt-get install -y --no-install-recommends \
    nginx-light && \
    rm -vf /etc/nginx/conf.d/default.conf && \
    rm -vrf /var/www/* && \
    usermod -aG www-data "${WEBUSER}" && \
    echo "========== Deploy MariaDB ==========" && \
    apt-get install -y --no-install-recommends \
    mariadb-server && \
    mkdir -p /run/mysqld && \
    chown -vR mysql:mysql /run/mysqld && \
    echo "========== Deploy FlightAirMap ==========" && \
    git clone --recursive https://github.com/Ysurac/FlightAirMap /var/www/flightairmap/htdocs && \
    pushd /var/www/flightairmap/htdocs && \
    cp -v /var/www/flightairmap/htdocs/install/flightairmap-nginx-conf.include /etc/nginx/flightairmap-nginx-conf.include && \
    chown -vR "${WEBUSER}":"${WEBUSER}" /var/www/flightairmap && \
    git log | head -1 | tr -s " " "_" | tee /VERSION || true && \
    rm -rf /var/www/flightairmap/htdocs/.git && \
    echo "========== Clean up ==========" && \
    apt-get remove -y \
    file \
    git \
    && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /src

# Copy config files
COPY rootfs/ /

EXPOSE 80
