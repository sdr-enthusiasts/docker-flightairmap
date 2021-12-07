FROM debian:stable-slim

ENV BASESTATIONPORT="30003" \
    FAM_BINGKEY="" \
    FAM_BITLYACCESSTOKENAPI="" \
    FAM_BRITISHAIRWAYSAPIKEY="" \
    FAM_CORSPROXY="https://galvanize-cors-proxy.herokuapp.com/" \
    FAM_FLIGHTAWAREPASSWORD="" \
    FAM_FLIGHTAWAREUSERNAME="" \
    FAM_GEOID_SOURCE="egm96-15" \
    FAM_GLOBALSITENAME="My FlightAirMap Site" \
    FAM_GLOBALURL="" \
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
    WEBUSER=flightairmap

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    KEPT_PACKAGES+=("ca-certificates") && \
    KEPT_PACKAGES+=("curl") && \
    TEMP_PACKAGES+=("git") && \
    KEPT_PACKAGES+=("html2text") && \
    KEPT_PACKAGES+=("jq") && \
    KEPT_PACKAGES+=("locales") && \
    KEPT_PACKAGES+=("procps") && \
    KEPT_PACKAGES+=("wget") && \
    KEPT_PACKAGES+=("pwgen") && \
    KEPT_PACKAGES+=("less") && \
    # php
    KEPT_PACKAGES+=("php") && \
    KEPT_PACKAGES+=("php-curl") && \
    KEPT_PACKAGES+=("php-fpm") && \
    KEPT_PACKAGES+=("php-gd") && \
    KEPT_PACKAGES+=("php-gettext") && \
    KEPT_PACKAGES+=("php-json") && \
    KEPT_PACKAGES+=("php-mysql") && \
    KEPT_PACKAGES+=("php-xml") && \
    KEPT_PACKAGES+=("php-zip") && \
    # nginx
    KEPT_PACKAGES+=("nginx-light") && \
    # mariadb
    KEPT_PACKAGES+=("mariadb-server") && \
    # s6-overlay
    TEMP_PACKAGES+=("file") && \
    TEMP_PACKAGES+=("gnupg") && \
    # install packages
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ${KEPT_PACKAGES[@]} \
        ${TEMP_PACKAGES[@]} \
        && \
    # set up user
    useradd -d "/home/${WEBUSER}" -m -r -U "${WEBUSER}" && \
    # setup locales
    echo "en_US ISO-8859-1" >> /etc/locale.gen && \
    echo "de_DE ISO-8859-1" >> /etc/locale.gen && \
    echo "es_ES ISO-8859-1" >> /etc/locale.gen && \
    echo "fr_FR ISO-8859-1" >> /etc/locale.gen && \
    locale-gen && \
    # php 7
    sed -i '/;error_log/c\error_log = /proc/self/fd/2' /etc/php/7.3/fpm/php-fpm.conf && \
    mkdir -p /run/php && \
    rm -vrf /etc/php/7.3/fpm/pool.d/* && \
    # nginx
    rm -vf /etc/nginx/conf.d/default.conf && \
    rm -vrf /var/www/* && \
    usermod -aG www-data "${WEBUSER}" && \
    # mariadb
    mkdir -p /run/mysqld && \
    chown -vR mysql:mysql /run/mysqld && \
    # flightairmap
    git clone --recursive https://github.com/Ysurac/FlightAirMap /var/www/flightairmap/htdocs && \
    pushd /var/www/flightairmap/htdocs && \
    cp -v /var/www/flightairmap/htdocs/install/flightairmap-nginx-conf.include /etc/nginx/flightairmap-nginx-conf.include && \
    chown -vR "${WEBUSER}":"${WEBUSER}" /var/www/flightairmap && \
    git log | head -1 | tr -s " " "_" | tee /VERSION || true && \
    rm -rf /var/www/flightairmap/htdocs/.git && \
    # s6 overlay
    curl \
        --location \
        -o /tmp/deploy-s6-overlay.sh \
        "https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh" \
        && \
    bash /tmp/deploy-s6-overlay.sh && \
    # clean up
    apt-get remove -y ${TEMP_PACKAGES[@]} && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/*

# Copy config files
COPY etc/ /etc/

ENTRYPOINT [ "/init" ]

EXPOSE 80
