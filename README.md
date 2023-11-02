# mikenye/flightairmap

Docker container for [FlightAirMap](http://flightairmap.com).

Builds and runs on x86_64, arm32v6, arm32v7 and arm64v8 (and possibly other architectures).

---

FlightAirMap is a fork of [barriespotter/Web_App](https://github.com/barriespotter/Web_App) with map, airspaces, PDO and ADS-B support.

Browse through the data based on a particular aircraft, airline or airport or search through the database. See extensive statistics such as most common aircraft type, airline, departure & arrival airport and busiest time of the day, or just explore flights.

Flights are displayed on 2D or 3D map with layer from : OpenStreetMap, Mapbox, MapQuest, Yandex, Bing, Google,...

Satellites can also be displayed on 3D map.

FlightAirMap also support marine (via AIS) and trackers.

You MUST have a source. No default sources are provided.

It can use as source ADS-B extended with format tsv, SBS (port 30003), raw (alpha support), VRS (aircraftlist.json), deltadb.txt from Radarcape and IVAO with format from phpVMS (/action.php/acars/data), whazzup, Virtual Airlines Manager,...

It also support glidernet APRS source.

This container is designed to work in conjunction with a Mode-S / BEAST provider. Check out [mikenye/readsb](https://hub.docker.com/repository/docker/mikenye/readsb) or [mikenye/piaware](https://hub.docker.com/repository/docker/mikenye/piaware) for this, or BYO.

---

## Container notes

On the first run of the container, the database will be created & populated and data will be downloaded from the internet. This process can take quite some time. On my system, around 30 minutes. Once the first run processes are finished, to access FlightAirMap, you can:

- Browse to `http://dockerhost:8080/` to access the FlightAirMap GUI.
- Browse to `http://dockerhost:8080/install/` to access the FlightAirMap settings area.

With regards to settings - where one exists, you should use an environment variable to set your desired setting. The environment variables get written to the `require/settings.php` file on container start, so any configuration items applied via `/install/` area may be overwritten. Long story short, your first port of call for configuration should be environment variables.

## Quick Start with `docker-compose`

**NOTE**: The Docker command provided in this quick start is given as an example and parameters should be adjusted to suit your needs.

**_NOTE:_**: This provided configuration doesn't work. You have to use the external database configuration. This is a known issue, and the config is being left in the README for reference and consideration as we decide what to do about this.

An example `docker-compose.yml` file is as follows:

```yaml
version: "2.0"

volumes:
  fam_db:
  fam_webapp:

services:
  flightairmap:
    image: ghcr.io/sdr-enthusiasts/docker-flightairmap:latest
    tty: true
    container_name: flightairmap
    restart: always
    ports:
      - 8080:80
    environment:
      - TZ=${FEEDER_TZ}
      - BASESTATIONHOST=readsb
      - FAM_INSTALLPASSWORD="very_secure_password_12345"
    volumes:
      - fam_db:/var/lib/mysql
      - fam_webapp:/var/www/flightairmap
```

## Quick Start with `docker-compose` using external database

**NOTE**: The Docker command provided in this quick start is given as an example and parameters should be adjusted to suit your needs.

An example `docker-compose.yml` file is as follows:

```yaml
version: "2.0"

volumes:
  fam_db:
  fam_webapp:

networks:
  flightairmap:

services:
  flightairmap_db:
    image: lscr.io/linuxserver/mariadb:latest
    tty: true
    container_name: flightairmap_db
    restart: always
    environment:
      - PUID=0
      - PGID=0
      - MYSQL_ROOT_PASSWORD=shai5Eisah7phe0aic5foote
      - MYSQL_DATABASE=flightairmap
      - MYSQL_USER=flightairmap
      - TZ=${FEEDER_TZ}
      - MYSQL_PASSWORD=xi6Paig4yeitae3Pah9aew3j
    volumes:
      - fam_db:/config

  flightairmap:
    image: ghcr.io/sdr-enthusiasts/docker-flightairmap:latest
    tty: true
    container_name: flightairmap
    restart: always
    ports:
      - 8080:80
    environment:
      - TZ=${FEEDER_TZ}
      - BASESTATIONHOST=readsb
      - FAM_INSTALLPASSWORD="very_secure_password_12345"
      - MYSQLHOSTNAME=flightairmap_db
      - MYSQLDATABASE=flightairmap
      - MYSQLUSERNAME=flightairmap
      - MYSQLPASSWORD=xi6Paig4yeitae3Pah9aew3j
      - MYSQLROOTPASSWORD=shai5Eisah7phe0aic5foote
    volumes:
      - fam_webapp:/var/www/flightairmap
    depends_on:
      - flightairmap_db
```

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable). Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Name                       | Description                                                                                                                                                                                                                                                                                                                                                 | Default                                             | Required  |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- | --------- |
| `TZ`                       | Your local timezone in "TZ database name" format [List-of-tz-database-time-zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).                                                                                                                                                                                                            | `UTC`                                               | Optional. |
| `FAM_INSTALLPASSWORD`      | Sets the `$globalInstallPassword` variable in `require/settings.php`. The password to access the install area. If not given, a randomly password will be generated and used. To obtain the generated password, you can issue the command `docker exec flightairmap cat /var/www/flightairmap/htdocs/require/settings.php \| grep globalInstallPassword`.    | `unset`                                             | Optional  |
| `BASESTATIONHOST`          | You can specify the IP or hostname of a host/container running `readsb` or `dump1090`. See [sdre-enthusiasts/docker-readsb-protobuf](https://github.com/sdr-enthusiasts/docker-readsb-protobuf/). If given, FlightAirMap will pull ADS-B data from the specified host/container. Without this, you'll need to set up your own sources via the install area. | `unset`                                             | Optional  |
| `BASESTATIONPORT`          | If your `readsb` or `dump1090` is running on a non-standard TCP port, you can change it here.                                                                                                                                                                                                                                                               | `30003`                                             | Optional  |
| `QUIET_FAM`                | If set to `true`, will suppress the output of FAM in the logs.                                                                                                                                                                                                                                                                                              | `true`                                              | Optional  |
| `FAM_GLOBALSITENAME`       | Sets the `$globalName` variable in `require/settings.php`.The name of your site                                                                                                                                                                                                                                                                             | `My FlightAirMap Site`                              | Optional  |
| `FAM_LANGUAGE`             | Sets the `$globalLanguage` variable in `require/settings.php`. Interface language. Can be set to `EN`, `DE` or `FR`                                                                                                                                                                                                                                         | `EN`                                                | Optional  |
| `FAM_MAPPROVIDER`          | Sets the `$globalMapProvider` variable in `require/settings.php`. Can be `Mapbox`, `OpenStreetMap`, `MapQuest-OSM` or `MapQuest-Aerial`                                                                                                                                                                                                                     | `OpenStreetMap`                                     | Optional  |
| `FAM_MAPBOXID`             | Sets the `$globalMapboxId` variable in `require/settings.php`                                                                                                                                                                                                                                                                                               | `examples.map-i86nkdio`                             | Optional  |
| `FAM_MAPBOXTOKEN`          | Sets the `$globalMapboxToken` variable in `require/settings.php`                                                                                                                                                                                                                                                                                            | `unset`                                             | Optional  |
| `FAM_GOOGLEKEY`            | Sets the `$globalGoogleAPIKey` variable in `require/settings.php`                                                                                                                                                                                                                                                                                           | `unset`                                             | Optional  |
| `FAM_BINGKEY`              | Sets the `$globalBingMapKey` variable in `require/settings.php`                                                                                                                                                                                                                                                                                             | `unset`                                             | Optional  |
| `FAM_MAPQUESTKEY`          | Sets the `$globalMapQuestKey` variable in `require/settings.php`                                                                                                                                                                                                                                                                                            | `unset`                                             | Optional  |
| `FAM_HEREAPPID`            | Sets the `$globalHereappID` variable in `require/settings.php`                                                                                                                                                                                                                                                                                              | `unset`                                             | Optional  |
| `FAM_HEREAPPCODE`          | Sets the `$globalHereappCode` variable in `require/settings.php`                                                                                                                                                                                                                                                                                            | `unset`                                             | Optional  |
| `FAM_OPENWEATHERMAPKEY`    | Sets the `$globalOpenWeatherMapKey` variable in `require/settings.php`                                                                                                                                                                                                                                                                                      | `unset`                                             | Optional  |
| `FAM_LATITUDEMAX`          | Sets the `$globalLatitudeMax` variable in `require/settings.php`                                                                                                                                                                                                                                                                                            | `46.92`                                             | Optional  |
| `FAM_LATITUDEMIN`          | Sets the `$globalLatitudeMin` variable in `require/settings.php`                                                                                                                                                                                                                                                                                            | 42.14`                                              | Optional  |
| `FAM_LONGITUDEMAX`         | Sets the `$globalLongitudeMax` variable in `require/settings.php`                                                                                                                                                                                                                                                                                           | `6.2`                                               | Optional  |
| `FAM_LONGITUDEMIN`         | Sets the `$globalLongitudeMin` variable in `require/settings.php`                                                                                                                                                                                                                                                                                           | `1.0`                                               | Optional  |
| `FAM_LATITUDECENTER`       | Sets the `$globalCenterLatitude` variable in `require/settings.php`                                                                                                                                                                                                                                                                                         | `46.38`                                             | Optional  |
| `FAM_LONGITUDECENTER`      | Sets the `$globalCenterLongitude` variable in `require/settings.php`                                                                                                                                                                                                                                                                                        | `5.29`                                              | Optional  |
| `FAM_LIVEZOOM`             | Sets the `$globalLiveZoom` variable in `require/settings.php`                                                                                                                                                                                                                                                                                               | `9`                                                 | Optional  |
| `FAM_SQUAWK_COUNTRY`       | Sets the `$globalSquawkCountry` variable in `require/settings.php`. Can be set to `UK`, `NZ`, `US`, `AU`, `NL`, `FR` or `TR`                                                                                                                                                                                                                                | `EU`                                                | Optional  |
| `FAM_SAILAWAYEMAIL`        | Sets the `$globalSailaway` array's `email` value in `require/settings.php`                                                                                                                                                                                                                                                                                  | `unset`                                             | Optional  |
| `FAM_SAILAWAYPASSWORD`     | Sets the `$globalSailaway` array's `password` value in `require/settings.php`                                                                                                                                                                                                                                                                               | `unset`                                             | Optional  |
| `FAM_SAILAWAYKEY`          | Sets the `$globalSailaway` array's `key` value in `require/settings.php`                                                                                                                                                                                                                                                                                    | `unset`                                             | Optional  |
| `FAM_BRITISHAIRWAYSAPIKEY` | Sets the `$globalBritishAirwaysKey` variable in `require/settings.php`                                                                                                                                                                                                                                                                                      | `unset`                                             | Optional  |
| `FAM_CORSPROXY`            | Sets the `$globalCORSproxy` variable in `require/settings.php`                                                                                                                                                                                                                                                                                              | [cors](https://galvanize-cors-proxy.herokuapp.com/) | Optional  |
| `FAM_LUFTHANSAKEY`         | Sets the `$globalLufthansaKey` array's `key` value in `require/settings.php`                                                                                                                                                                                                                                                                                | `unset`                                             | Optional  |
| `FAM_LUFTHANSASECRET`      | Sets the `$globalLufthansaKey` array's `secret` value in `require/settings.php`                                                                                                                                                                                                                                                                             | `unset`                                             | Optional  |
| `FAM_FLIGHTAWAREUSERNAME`  | Sets the `$globalFlightAwareUsername` variable in `require/settings.php`                                                                                                                                                                                                                                                                                    | `unset`                                             | Optional  |
| `FAM_FLIGHTAWAREPASSWORD`  | Sets the `$globalFlightAwarePassword` variable in `require/settings.php`                                                                                                                                                                                                                                                                                    | `unset`                                             | Optional  |
| `FAM_MAPMATCHINGSOURCE`    | Sets the `$globalMapMatchingSource` variable in `require/settings.php`                                                                                                                                                                                                                                                                                      | `fam`                                               | Optional  |
| `FAM_GRAPHHOPPERAPIKEY`    | Sets the `$globalGraphHopperKey` variable in `require/settings.php`                                                                                                                                                                                                                                                                                         | `unset`                                             | Optional  |
| `FAM_NOTAMSOURCE`          | Sets the `$globalNOTAMSource` variable in `require/settings.php`                                                                                                                                                                                                                                                                                            | `unset`                                             | Optional  |
| `FAM_METARSOURCE`          | Sets the `$globalMETARurl` variable in `require/settings.php`                                                                                                                                                                                                                                                                                               | `unset`                                             | Optional  |
| `FAM_BITLYACCESSTOKENAPI`  | Sets the `$globalBitlyAccessToken` variable in `require/settings.php`                                                                                                                                                                                                                                                                                       | `unset`                                             | Optional  |
| `FAM_GEOID_SOURCE`         | Sets the `$globalGeoidSource` variable in `require/settings.php`                                                                                                                                                                                                                                                                                            | `egm96-15`                                          | Optional  |
| `FAM_ENABLE_ACARS`         | Sets the `$globalACARS` variable in `require/settings.php`                                                                                                                                                                                                                                                                                                  | `false`                                             | Optional  |
| `FAM_GLOBAL_URL`           | Sets the `$globalURL` variable in `require/settings.php`. Default is unset. Sets the URL pathing for asset requests. Useful for running FAM behind a proxy. No trailing `/`                                                                                                                                                                                 | `unset`                                             | Optional  |

If you wish to use an external database:

| Name            | Description                                         | Default         | Required                                                 |
| --------------- | --------------------------------------------------- | --------------- | -------------------------------------------------------- |
| `MYSQLHOSTNAME` | Sets the hostname of the mysql/mariadb server.      | `unset`         | Required for external databases, else please leave unset |
| `MYSQLPORT`     | Sets the port used to communicate to mysql/mariadb. | `3306`          | Required for external databases, else please leave unset |
| `MYSQLDATABASE` | Sets the mysql/mariadb database name.               | `flightairmap`. | Required for external databases, else please leave unset |
| `MYSQLUSERNAME` | Sets the mysql/mariadb user name.                   | `flightairmap`. | Required for external databases, else please leave unset |
| `MYSQLPASSWORD` | Sets the mysql/mariadb password.                    | `unset`         | Required for external databases, else please leave unset |

### Data Volumes

The following table describes data volumes used by the container. The mappings
are set via the `-v` parameter. Each mapping is specified with the following
format: `<VOL_NAME>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path          | Permissions | Description                                                                     |
| ----------------------- | ----------- | ------------------------------------------------------------------------------- |
| `/var/lib/mysql`        | rw          | This is where the application database resides, if using the internal database. |
| `/var/www/flightairmap` | rw          | This is where the application itself resides.                                   |

It is suggested to make docker volumes for both of these areas, with the `docker volume create` command, and assign the volumes to the paths above.

### Ports

Here is the list of ports used by the container. They can be mapped to the host
via the `-p` parameter (one per port mapping). Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`. The port number inside the
ainer cannot be changed, but you are free to use any port on the host side.

| Container Port | Purpose                                                                                                  |
| -------------- | -------------------------------------------------------------------------------------------------------- |
| 80 (tcp)       | FlightAirMap application, web server                                                                     |
| 9999 (udp)     | [ACARS UDP Messages](https://github.com/valeriosouza/FlightAirMap#acars-only-messages-from-real-flights) |

## Getting Help

Having troubles with the container or have questions? Please [create a new issue](https://github.com/mikenye/docker-flightairmap/issues).

I also have a [Discord channel](https://discord.gg/sTf9uYF), feel free to [join](https://discord.gg/sTf9uYF) and converse.
