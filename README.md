# Cups Google/Air Print

## ARCHIVED!

Google print is being deprecated which means this container no longer really needs to exist. It still works, but there are still issues with it that I never resolved. Check out [tigerj/cups-airprint](https://hub.docker.com/r/tigerj/cups-airprint), it seems like a very good cups container.

Inspired by [mnbf9rca/cups-google-print](https://github.com/mnbf9rca/cups-google-print)

Built with metal in mind (a physical linux server/system).

> Please log issues on GitHub (https://github.com/docquantum/cups-google-air-print) (pull requests welcome)

Docker container with CUPS, Apple AirPrint (Avahi) and Google Cloud Print.

## Usage
### Configure mappings:

| Type     | Container                | Host                                                                                                                                                   |
| -------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Device   | /dev/usb/path/to/printer | /dev/usb/path/to/printer                                                                                                                               |
| Path     | /var/run/dbus            | /var/run/dbus (optional)                                                                                                                               |
| Path     | /data                    | wherever you want config files stored                                                                                                                  |
| Variable | CUPS_USER_ADMIN          | For logging in to CUPS (default "cupsgcp")                                                                                                             |
| Variable | CUPS_USER_PASSWORD       | Password to login (default "password")                                                                                                                 |
| Variable | DBUS                     | Set to run dbus within the container config (default "true")                                                                                           |
| Variable | DRIVER_PKGS              | Space seperated list of packages to send to apt-get to install from Ubuntu repos. Useful for drivers you need for your printer, or extra CUPS plugins. |

### Other requirements
- Host networking `--net="host"` appears to be needed for GCP and Avahi to work (mDNS advertisement on the host subnet so that other devices can find the printers on the network)
- To attach your printer to the server, use `--device=/path/to/host/dev:/path/to/container/dev` to properly map to the container. It negates the need to run the container in privileged mode. To find what USB the printer is on, run `lsusb` in the host container.
- Avahi and GCP need dbus to run, so the container comes with it. There is an option to use the host's dbus; you can map `/var/run/dbus` to the host and then set `DBUS` to false.

### Setup Google Cloud Print
Since GCP needs to be configured to allow for printing outside the network, a one-shot docker command can be run to run the built in interactive config tool. By default, a config file is generated on first run with local printing only if it does not exists.

To run the tool, make sure the directories exist in the first place: `/data/gcp` or on host: `/path/to/container/gcp`

Then run the one shot command:
```
docker run --rm -it -v /path/to/data:/data docquantum/cups-google-air-print gcp-connector-util --config-filename /data/gcp/gcp-cups-connector.config.json init"
```
It will ask you config options, and upon completion, should say
`The config file /data/gcp/gcp-cups-connector.config.json is ready to rock`

You can also visit [the wiki](https://github.com/google/cloud-print-connector/wiki/Configuration) for infor and edit the file directly, or create one yourself.

### Docker Run
Typical startup command might be:
```
docker run -d \
    --name="cups-gcp" \
    --restart="unless-stopped" \
    --net="host" \
    --device=/dev/bus/usb:/dev/bus/usb \
    -e "TZ"="America/Arizona" \
    -e "CUPS_USER_ADMIN"="admin" \
    -e "CUPS_USER_PASSWORD"="pass123" \
    -e "DBUS"="TRUE" \
    -e "DRIVER_PKGS"="printer-driver-gutenprint foomatic-db" \
    -v "/home/user/containers/cups-gcp":"/data" \
    docquantum/cups-google-air-print
```

### Docker Compose
Typical compose file might be:
```
version: '3'
services:
    cups-gcp:
        image: docquantum/cups-google-air-print
        container_name: cups-gcp
        restart: unless-stopped
        network_mode: host
        devices:
            - "/dev/bus/usb:/dev/bus/usb"
        volumes:
            - "/home/user/containers/cups-gcp:/data"
        environment:
            - "TZ=America/Arizona"
            - "CUPS_USER_ADMIN=admin"
            - "CUPS_USER_PASSWORD=pass123"
            - "DBUS=TRUE"
            - "DRIVER_PKGS=printer-driver-gutenprint foomatic-db"
```
