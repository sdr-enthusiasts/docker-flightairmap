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

## Quick Start with `docker run`

**NOTE**: The Docker command provided in this quick start is given as an example and parameters should be adjusted to suit your needs.

Launch the FlightAwareMap docker container with the following commands:

```shell
docker volume create flightairmap_db
docker volume create flightairmap_webapp
docker run -d \
    --name=flightairmap \
    -p 8080:80 \
    -e BASESTATIONHOST=readsb \
    -e TZ=Australia/Perth \
    -e FAM_INSTALLPASSWORD="very_secure_password_12345" \
    -v flightairmap_db:/var/lib/mysql \
    -v flightairmap_webapp:/var/www/flightairmap \
    mikenye/flightairmap
```

On the first run of the container, the database will be created & populated and data will be downloaded from the internet. This process can take quite some time. On my system, around 30 minutes. Once the first run processes are finished, to access FlightAirMap, you can:

* Browse to `http://dockerhost:8080/` to access the FlightAirMap GUI.
* Browse to `http://dockerhost:8080/install/` to access the FlightAirMap settings area.

With regards to settings - where one exists, you should use an environment variable to set your desired setting. The environment variables get written to the `require/settings.php` file on container start, so any configuration items applied via `/install/` area may be overwritten. Long story short, your first port of call for configuration should be environment variables.

## Quick Start with `docker-compose`

**NOTE**: The Docker command provided in this quick start is given as an example and parameters should be adjusted to suit your needs.

An example `docker-compose.yml` file is as follows:

```yaml
version: '2.0'

volumes:
  fam_db:
  fam_webapp:

services:

  flightairmap:
    image: mikenye/flightairmap:latest
    tty: true
    container_name: flightairmap
    restart: always
    ports:
      - 8080:80
    environment:
      - TZ=Australia/Perth
      - BASESTATIONHOST=readsb
      - FAM_INSTALLPASSWORD="very_secure_password_12345"
    volumes:
      - fam_db:/var/lib/mysql
      - fam_webapp:/var/www/flightairmap
```

On the first run of the container, the database will be created & populated and data will be downloaded from the internet. This process can take quite some time. On my system, around 30 minutes. Once the first run processes are finished, to access FlightAirMap, you can:

* Browse to `http://dockerhost:8080/` to access the FlightAirMap GUI.
* Browse to `http://dockerhost:8080/install/` to access the FlightAirMap settings area.

With regards to settings - where one exists, you should use an environment variable to set your desired setting. The environment variables get written to the `require/settings.php` file on container start, so any configuration items applied via with `/install/` area may be overwritten. Long story short, your first port of call for configuration should be environment variables.

## Quick Start with `docker-compose` using external database

**NOTE**: The Docker command provided in this quick start is given as an example and parameters should be adjusted to suit your needs.

An example `docker-compose.yml` file is as follows:

```yaml
version: '2.0'

volumes:
  fam_db:
  fam_webapp:

networks:
  flightairmap:

services:

  flightairmap_db:
    image: mariadb
    command: --default-authentication-plugin=mysql_native_password
    tty: true
    container_name: flightairmap_db
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=shai5Eisah7phe0aic5foote
      - MYSQL_DATABASE=flightairmap
      - MYSQL_USER=flightairmap
      - MYSQL_PASSWORD=xi6Paig4yeitae3Pah9aew3j
    volumes:
      - fam_db:/var/lib/mysql
    networks:
      - flightairmap

  flightairmap:
    image: famtest:latest
    tty: true
    container_name: flightairmap
    restart: always
    ports:
      - 8080:80
    environment:
      - TZ=Australia/Perth
      - BASESTATIONHOST=readsb
      - FAM_INSTALLPASSWORD="very_secure_password_12345"
      - MYSQLHOSTNAME=flightairmap_db
      - MYSQLDATABASE=flightairmap
      - MYSQLUSERNAME=flightairmap
      - MYSQLPASSWORD=xi6Paig4yeitae3Pah9aew3j
      - MYSQLROOTPASSWORD=shai5Eisah7phe0aic5foote
    volumes:
      - fam_webapp:/var/www/flightairmap
    networks:
      - flightairmap
    depends_on:
      - flightairmap_db
```

On the first run of the container, the database will be created & populated and data will be downloaded from the internet. This process can take quite some time. On my system, around 30 minutes. Once the first run processes are finished, to access FlightAirMap, you can:

* Browse to `http://dockerhost:8080/` to access the FlightAirMap GUI.
* Browse to `http://dockerhost:8080/install/` to access the FlightAirMap settings area.

With regards to settings - where one exists, you should use an environment variable to set your desired setting. The environment variables get written to the `require/settings.php` file on container start, so any configuration items applied via with `/install/` area may be overwritten. Long story short, your first port of call for configuration should be environment variables.

## Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Environment Variable | Explanation |
|----------------------|-------------|
| `TZ` | Your local timezone in "TZ database name" format [List-of-tz-database-time-zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). Default `UTC`. Optional. |
| `DEBUG_LOGGING` | Set to any value to enable debug logging. Default is unset. Optional. |

### Install Script Configuration

| Environment Variable | Controls which variable<br />in `require/settings.php` | Controls which variable<br />on install page | Explanation |
|----------------------|--------------------------------------------------------|----------------------------------------------|-------------|
| `FAM_INSTALLPASSWORD` | `$globalInstallPassword` | Install password | The password to access the install area. If not given, a randomly password will be generated and used. To obtain the generated password, you can issue the command `docker exec flightairmap grep globalInstallPassword /var/www/flightairmap/htdocs/require/settings.php`. Optional. |

### Site Configuration

| Environment Variable | Controls which<br />variable in<br />`require/settings.php` | Controls which<br />variable on<br />install page | Explanation |
|----------------------|--------------------------------------------------------|----------------------------------------------|-------------|
| `FAM_GLOBALSITENAME` | `$globalName` | Site name | The name of your site. Default `My FlightAirMap Site`. Optional. |
| `FAM_GLOBALURL` | `$globalURL` | Site directory | Set to the site's base URL, if hosting the site with an alternate base URL. For example, if the complete URL is `http://your_hostname/flightairmap`, set this to `/flightairmap`. |
| `FAM_GLOBALTIMEZONE` | `$globalTimezone` | Timezone | The timezone for your FlightAirMap installation, in "TZ database name" format [List-of-tz-database-time-zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). Optional. If not set, will be set to the value of `TZ`. |
| `FAM_LANGUAGE` | `$globalLanguage` | Language | Interface language. Can be set to `EN`, `DE` or `FR`. Default `EN`. Optional. |

### Map Provider

| Environment Variable | Controls which<br />variable in<br />`require/settings.php` | Controls which<br />variable on<br />install page | Explanation |
|----------------------|--------------------------------------------------------|----------------------------------------------|-------------|
| `FAM_MAPPROVIDER` | `$globalMapProvider` | Default map provider | Can be `Mapbox`, `OpenStreetMap`, `MapQuest-OSM` or `MapQuest-Aerial`. Default `OpenStreetMap`. Optional. |
| `FAM_MAPBOXID` | `$globalMapboxId` | Mapbox id | If using Mapbox, you can optionally set your Mapbox ID. Default: "examples.map-i86nkdio". Optional. |
| `FAM_MAPBOXTOKEN` | `$globalMapboxToken` | Mapbox token | If using Mapbox, you can optionally set your Mapbox token. Default is unset. Optional. |
| `FAM_GOOGLEKEY` | `$globalGoogleAPIKey` | Google API key | If using Google Maps, you can optionally set your Google Maps API key. Default is unset. Optional. |
| `FAM_BINGKEY` | `$globalBingMapKey` | Bing Map key | If using Bing Maps, you can optionally set your Bing Maps key. Default is unset. Optional. |
| `FAM_MAPQUESTKEY` | `$globalMapQuestKey` | MapQuest key | If using MapQuest, you can optionally set your MapQuest key. Default is unset. Optional. |
| `FAM_HEREAPPID` | `$globalHereappID` | Here App_Id | If using Here, you can optionally set your App_Id. Default is unset. Optional. |
| `FAM_HEREAPPCODE` | `$globalHereappCode` | Here App_Code | If using Here, you can optionally set your App_Code. Default is unset. Optional. |
| `FAM_OPENWEATHERMAPKEY` | `$globalOpenWeatherMapKey` | OpenWeatherMap key (weather layer) | If using OpenWeatherMap, you can optionally set your key. Default is unset. Optional. |

Map Provider API Access:

* You can apply for Mapbox API access here: <https://www.mapbox.com/developers/>
* You can apply for Google Maps API access here: <https://developers.google.com/maps/documentation/javascript/get-api-key#get-an-api-key>
* You can apply for Bing Maps API access here: <https://www.bingmapsportal.com/>
* You can apply for MapQuest API access here: <https://developer.mapquest.com/user/me/apps>
* You can apply for Here API access here: <https://developer.here.com/rest-apis/documentation/enterprise-map-tile/topics/quick-start.html>
* You can apply for OpenWeatherMap API access here: <https://openweathermap.org/>

### Offline Mode

| Environment Variable | Controls which<br />variable in<br />`require/settings.php` | Controls which<br />variable on<br />install page | Explanation |
|----------------------|--------------------------------------------------------|----------------------------------------------|-------------|
| `FAM_GLOBALMAPOFFLINE` | `$globalMapOffline` | Map offline mode | Set to any value, and map offline mode will not use network to display map but Natural Earth. Default is unset. Optional. |
| `FAM_GLOBALOFFLINE` | `$globalOffline` | Offline mode | Set to any value, and backend will not use network. Default is unset. Optional.

### Coverage Area

| Environment Variable | Controls which<br />variable in<br />`require/settings.php` | Controls which<br />variable on<br />install page | Explanation |
|----------------------|--------------------------------------------------------|----------------------------------------------|-------------|
| `FAM_LATITUDEMAX` | `$globalLatitudeMax` | The maximum latitude (north) | Default is `46.92`. Optional. |
| `FAM_LATITUDEMIN` | `$globalLatitudeMin` | The minimum latitude (south) | Default is `42.14`. Optional. |
| `FAM_LONGITUDEMAX` | `$globalLongitudeMax` | The maximum longitude (west) | Default is `6.2`. Optional. |
| `FAM_LONGITUDEMIN` | `$globalLongitudeMin` | The minimum longitude (east) | Default is `1.0`. Optional. |
| `FAM_LATITUDECENTER` | `$globalCenterLatitude` | The latitude center | Default is `46.38`. Optional. |
| `FAM_LONGITUDECENTER` | `$globalCenterLongitude` | The longitude center | Default is `5.29`. Optional. |
| `FAM_LIVEZOOM` | `$globalLiveZoom` | Default Zoom on live map | Default is `9`. Optional. |
| `FAM_SQUAWK_COUNTRY` | `$globalSquawkCountry` | Country for squawk usage | Can be set to `UK`, `NZ`, `US`, `AU`, `NL`, `FR` or `TR`. Default `EU`. Optional. |

### Data Source

#### Virtual Marine

| Environment Variable | Controls which<br />variable in<br />`require/settings.php` | Controls which<br />variable on<br />install page | Explanation |
|----------------------|--------------------------------------------------------|----------------------------------------------|-------------|
| `FAM_GLOBALVM` | `$globalVM` | Virtual marine (checkbox) | Set to any value to enable virtual marine. Default is unset. Optional. |
| `FAM_SAILAWAYEMAIL` | `$globalSailaway` | Sailaway email | If using Sailaway full format, set this to your sailaway email. Default is unset. Optional. |
| `FAM_SAILAWAYPASSWORD` | `$globalSailaway` | Sailaway password | If using Sailaway full format, set this to your sailaway password. Default is unset. Optional. |
| `FAM_SAILAWAYKEY` | `$globalSailaway` | Sailaway API key | If using Sailaway full format, set this to your sailaway API key. Default is unset. Optional. |

### Sources

| Environment Variable | Controls which<br />variable in<br />`require/settings.php` | Controls which<br />variable on<br />install page | Explanation |
|----------------------|--------------------------------------------------------|----------------------------------------------|-------------|
| `FAM_GLOBALSOURCES` | `$globalSources` | Sources | See below. |

The `FAM_GLOBALSOURCES` variable allows you to configure outgoing connections. The variable takes a semicolon (`;`) separated list of:

```
  host_or_url,port_or_callback,format,name,source_stats,no_archive,timezone
```

...where:

* `host_or_url` is the hostname, IP address or URL of the source data provider. This corresponds to the "Host/URL" column on the install page.
* `port_or_callback` is the TCP port, UDP port or callback password of the source data provider. This corresponds to the "Port/Callback Pass" column on the install page.
* `format` is the format of the source data. See below for the list of supported values and what format they correspond to.
* `source_stats` is whether or not the "Source Stats" column is checked on the install page.
* `no_archive` is whether or not the "No Archive" column is checked on the install page.
* `timezone` is the timezone of the data source in "TZ database name" format [List-of-tz-database-time-zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

The `format` setting can be one of the following:

| `format` setting | Corresponds to Format column<br />drop-down on the install page |
|------------------|------------------------------------------------------------|
| `auto` | Auto |
| `sbs` | SMS |
| `tsv` | TSV |
| `raw` | Raw |
| `aircraftjson` | Dump1090 aircraft.json |
| `planefinderclient` | Planefinder client |
| `aprs` | APRS |
| `deltadbtxt` | Radarcape deltadb.txt |
| `radarcapejson` | Radarcape json |
| `vatsimtxt` | Vatsim |
| `aircraftlistjson` | Virtual Radar Server AircraftList.json |
| `vrstcp` | "Virtual Radar Server TCP" |
| `phpvmacars` | phpVMS |
| `vaos` | Virtual Airline Operations System (VAOS) |
| `vam` | Virtual Airlines Manager |
| `whazzup` | IVAO |
| `flightgearmp` | FlightGear Multiplayer |
| `flightgearsp` | FlightGear Singleplayer |
| `acars` | ACARS from acarsdec/acarsdeco2 over UDP |
| `acarssbs3` | ACARS SBS-3 over TCP |
| `acarsjson` | ACARS from acarsdec json and vdlm2dec |
| `acarsjsonudp` | ACARS from acarsdec json and vdlm2dec over UDP |
| `ais` | NMEA AIS over TCP |
| `airwhere` | AirWhere website |
| `hidnseek_callback` | HidnSeek Callback |
| `blitzortung` | Blitzortung |
| `sailaway` | Sailaway |
| `sailawayfull` | Sailaway with missions, races,... |

For example:

To read SBS data from a host:

```
FAM_GLOBALSOURCES=192.168.100.100,30003,sbs,Basestation Data,false,false,UTC
```

Note, the following command line arguments are deprecated, but I will continue to support them for as long as possible to not break existing installations:

* `BASESTATIONHOST`: You can specify the IP or hostname of a host/container running `readsb` or `dump1090`. See [mikenye/readsb](https://hub.docker.com/r/mikenye/readsb). If given, FlightAirMap will pull ADS-B data from the specified host/container. Without this, you'll need to set up your own sources via the install area. Default is unset. Optional.
* `BASESTATIONPORT`: If your `readsb` or `dump1090` is running on a non-standard TCP port, you can change it here. Default `30003`. Optional.


### NOT YET OVERHAULED


`FAM_BRITISHAIRWAYSAPIKEY`: Sets the `$globalBritishAirwaysKey` variable in `require/settings.php`. Default is unset. Optional.

`FAM_CORSPROXY`: Sets the `$globalCORSproxy` variable in `require/settings.php`. Default `https://galvanize-cors-proxy.herokuapp.com/`. Optional.

`FAM_LUFTHANSAKEY`: Sets the `$globalLufthansaKey` array's `key` value in `require/settings.php`. Default is unset. Optional.

`FAM_LUFTHANSASECRET`: Sets the `$globalLufthansaKey` array's `secret` value in `require/settings.php`. Default is unset. Optional.

`FAM_FLIGHTAWAREUSERNAME`: Sets the `$globalFlightAwareUsername` variable in `require/settings.php`. Default is unset. Optional.

`FAM_FLIGHTAWAREPASSWORD`: Sets the `$globalFlightAwarePassword` variable in `require/settings.php`. Default is unset. Optional.

`FAM_MAPMATCHINGSOURCE`: Sets the `$globalMapMatchingSource` variable in `require/settings.php`. Default is `fam`. Optional.

`FAM_GRAPHHOPPERAPIKEY`: Sets the `$globalGraphHopperKey` variable in `require/settings.php`. Default is unset. Optional.

`FAM_NOTAMSOURCE`: Sets the `$globalNOTAMSource` variable in `require/settings.php`. Default is unset. Optional.

`FAM_METARSOURCE`: Sets the `$globalMETARurl` variable in `require/settings.php`. Default is unset. Optional.

`FAM_BITLYACCESSTOKENAPI`: Sets the `$globalBitlyAccessToken` variable in `require/settings.php`. Default is unset. Optional.

`FAM_GEOID_SOURCE` Sets the `$globalGeoidSource` variable in `require/settings.php`. Default `egm96-15`. Optional.

If you wish to use an external database:

`MYSQLHOSTNAME` Sets the hostname of the mysql/mariadb server.

`MYSQLPORT` Sets the port used to communicate to mysql/mariadb. Default `3306`. Optional.

`MYSQLDATABASE` Sets the mysql/mariadb database name. Default `flightairmap`. Optional.

`MYSQLUSERNAME` Sets the mysql/mariadb user name. Default `flightairmap`. Optional.

`MYSQLPASSWORD` Sets the mysql/mariadb password.

## Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<VOL_NAME>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/var/lib/mysql`| rw | This is where the application database resides, if using the internal database. |
|`/var/www/flightairmap`| rw | This is where the application itself resides. |

It is suggested to make docker volumes for both of these areas, with the `docker volume create` command, and assign the volumes to the paths above.

## Ports

Here is the list of ports used by the container.  They can be mapped to the host
via the `-p` parameter (one per port mapping).  Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`.  The port number inside the
ainer cannot be changed, but you are free to use any port on the host side.

| Container Port | Purpose |
|----------------|---------|
| 80 (tcp)       | FlightAirMap application, web server |

## Getting Help

Having troubles with the container or have questions?  Please [create a new issue](https://github.com/mikenye/docker-flightairmap/issues).

I also have a [Discord channel](https://discord.gg/sTf9uYF), feel free to [join](https://discord.gg/sTf9uYF) and converse.
