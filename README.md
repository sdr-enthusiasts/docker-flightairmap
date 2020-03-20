# Docker container for FlightAirMap

Docker container for [FlightAirMap](http://flightairmap.com).

Builds and runs on x86_64, arm32v7 and arm64v8 (and possibly other architectures).

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

```
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

On the first run of the container, the database will be populated and data will be downloaded from the internet. This process can take quite some time. On my system, around 30 minutes. Once the first run processes are finished, to access FlightAirMap, you can:

* Browse to `http://dockerhost:8080/` to access the FlightAirMap GUI.
* Browse to `http://dockerhost:8080/install/` to access the FlightAirMap settings area.

With regards to settings - where one exists, you should use an environment variable to set your desired setting. The environment variables get written to the `require/settings.php` file on container start, so any configuration items applied via `/install/` area may be overwritten. Long story short, your first port of call for configuration should be environment variables.

## Quick Start with `docker-compose`

**NOTE**: The Docker command provided in this quick start is given as an example and parameters should be adjusted to suit your needs.

An example `docker-compose.yml` file is as follows:

```
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

On the first run of the container, the database will be populated and data will be downloaded from the internet. This process can take quite some time. On my system, around 30 minutes. Once the first run processes are finished, to access FlightAirMap, you can:

* Browse to `http://dockerhost:8080/` to access the FlightAirMap GUI.
* Browse to `http://dockerhost:8080/install/` to access the FlightAirMap settings area.

With regards to settings - where one exists, you should use an environment variable to set your desired setting. The environment variables get written to the `require/settings.php` file on container start, so any configuration items applied via with `/install/` area may be overwritten. Long story short, your first port of call for configuration should be environment variables.

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

`TZ`: Your local timezone in "TZ database name" format [List-of-tz-database-time-zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). Default `UTC`. Optional.

`FAM_INSTALLPASSWORD`: Sets the `$globalInstallPassword` variable in `require/settings.php`. The password to access the install area. If not given, a randomly password will be generated and used. To obtain the generated password, you can issue the command `docker exec flightairmap cat /var/www/flightairmap/htdocs/require/settings.php | grep globalInstallPassword`. Optional.

`BASESTATIONHOST`: You can specify the IP or hostname of a host/container running `readsb` or `dump1090`. See [mikenye/readsb](https://hub.docker.com/r/mikenye/readsb). If given, FlightAirMap will pull ADS-B data from the specified host/container. Without this, you'll need to set up your own sources via the install area. Default is unset. Optional.

`BASESTATIONPORT`: If your `readsb` or `dump1090` is running on a non-standard TCP port, you can change it here. Default `30003`. Optional.

`FAM_GLOBALSITENAME`: Sets the `$globalName` variable in `require/settings.php`.The name of your site. Default `My FlightAirMap Site`. Optional.

`FAM_LANGUAGE`: Sets the `$globalLanguage` variable in `require/settings.php`. Interface language. Can be set to `EN`, `DE` or `FR`. Default `EN`. Optional.

`FAM_MAPPROVIDER`: Sets the `$globalMapProvider` variable in `require/settings.php`. Can be `Mapbox`, `OpenStreetMap`, `MapQuest-OSM` or `MapQuest-Aerial`. Default `OpenStreetMap`. Optional.

`FAM_MAPBOXID`: Sets the `$globalMapboxId` variable in `require/settings.php`. Default: "examples.map-i86nkdio" Optional.

`FAM_MAPBOXTOKEN`: Sets the `$globalMapboxToken` variable in `require/settings.php`. Default is unset. Optional.

`FAM_GOOGLEKEY`: Sets the `$globalGoogleAPIKey` variable in `require/settings.php`. Default is unset. Optional.

`FAM_BINGKEY`: Sets the `$globalBingMapKey` variable in `require/settings.php`. Default is unset. Optional.

`FAM_MAPQUESTKEY`: Sets the `$globalMapQuestKey` variable in `require/settings.php`. Default is unset. Optional.

`FAM_HEREAPPID`: Sets the `$globalHereappID` variable in `require/settings.php`. Default is unset. Optional.

`FAM_HEREAPPCODE`: Sets the `$globalHereappCode` variable in `require/settings.php`. Default is unset. Optional.

`FAM_OPENWEATHERMAPKEY`: Sets the `$globalOpenWeatherMapKey` variable in `require/settings.php`. Default is unset. Optional.

`FAM_LATITUDEMAX`: Sets the `$globalLatitudeMax` variable in `require/settings.php`. Default is `46.92`. Optional.

`FAM_LATITUDEMIN`: Sets the `$globalLatitudeMin` variable in `require/settings.php`. Default is `42.14`. Optional.

`FAM_LONGITUDEMAX`: Sets the `$globalLongitudeMax` variable in `require/settings.php`. Default is `6.2`. Optional.

`FAM_LONGITUDEMIN`: Sets the `$globalLongitudeMin` variable in `require/settings.php`. Default is `1.0`. Optional.

`FAM_LATITUDECENTER`: Sets the `$globalCenterLatitude` variable in `require/settings.php`. Default is `46.38`. Optional.

`FAM_LONGITUDECENTER`: Sets the `$globalCenterLongitude` variable in `require/settings.php`. Default is `5.29`. Optional.

`FAM_LIVEZOOM`: Sets the `$globalLiveZoom` variable in `require/settings.php`. Default is `9`. Optional.

`FAM_SQUAWK_COUNTRY`: Sets the `$globalSquawkCountry` variable in `require/settings.php`. Can be set to `UK`, `NZ`, `US`, `AU`, `NL`, `FR` or `TR`. Default `EU`. Optional.

`FAM_SAILAWAYEMAIL`: Sets the `$globalSailaway` array's `email` value in `require/settings.php`. Default is unset. Optional.

`FAM_SAILAWAYPASSWORD`: Sets the `$globalSailaway` array's `password` value in `require/settings.php`. Default is unset. Optional.

`FAM_SAILAWAYKEY`: Sets the `$globalSailaway` array's `key` value in `require/settings.php`. Default is unset. Optional.

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

### Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<VOL_NAME>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/var/lib/mysql`| rw | This is where the application database resides. |
|`/var/www/flightairmap`| rw | This is where the application itself resides. |

It is suggested to make docker volumes for both of these areas, with the `docker volume create` command, and assign the volumes to the paths above.

### Ports

Here is the list of ports used by the container.  They can be mapped to the host
via the `-p` parameter (one per port mapping).  Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`.  The port number inside the
ainer cannot be changed, but you are free to use any port on the host side.

| Container Port | Purpose |
|----------------|---------|
| 80 (tcp)       | FlightAirMap application, web server |

## Getting Help

Having troubles with the container or have questions?  Please [create a new issue](https://github.com/mikenye/docker-flightairmap/issues).
