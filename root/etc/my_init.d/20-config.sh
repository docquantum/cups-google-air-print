#!/bin/bash

set -e

echo -e "\n***** Copy default configs, modify values to dockerize *****\n"

# Create dirs
mkdir -p /data/{cups,gcp,avahi,log}
mkdir -p /data/log/{cups,gcp}
mkdir -p /data/cups/ssl

# Create dbus service
if [ ${DBUS,,} == "true" ]; then
    echo "Enabling DBUS"

    dbus-uuidgen > /var/lib/dbus/machine-id
    mkdir -p /var/run/dbus
    mkdir -p /etc/service/dbus
    
    cat > /etc/service/dbus/run <<EOF
#!/bin/sh

# Start Dbus daemon
exec 2>&1
exec /usr/bin/dbus-daemon --nofork --nosyslog --config-file=/data/dbus/system.conf
EOF
    
    chmod +x /etc/service/dbus/run

    if [ ! -f /data/dbus/system.conf ]; then
        mkdir -p /data/dbus
        cp -v /usr/share/dbus-1/system.conf /data/dbus/system.conf
    fi
fi

# Check for CUPS config, copy default if it doesn't exist.
if [ ! -f /data/cups/cupsd.conf ]; then
    echo -e "\n--------------------------------------------------------------------------------"
    echo "cupsd.conf not found, copying and modifying defaults..."
    cp -v /etc/cups/cupsd.conf /data/cups/cupsd.conf
    echo "Changing localhost to * to allow local network access..."
    sed -i 's+Listen localhost:631+Listen *:631+g' /data/cups/cupsd.conf
    echo "Changing Browsing Off to On to allow for sharing of printers on network..."
    sed -i 's+Browsing Off+Browsing On+g' /data/cups/cupsd.conf
    echo "Allowing local network access to web interface..."
    sed -i 's+</Location>+  Allow @LOCAL\n</Location>+g' /data/cups/cupsd.conf
fi
if [ ! -f /data/cups/cups-files.conf ]; then
    echo -e "\n--------------------------------------------------------------------------------"
    echo "cups-files.conf not found, copying and modifying default."
    cp -v /etc/cups/cups-files.conf /data/cups/cups-files.conf
    echo "Moving logs to /data/logs/cups"
    sed -i 's+/var/log/cups+/data/log/cups+g' /data/cups/cups-files.conf
    sed -i 's+#ServerRoot /etc/cups+ServerRoot /data/cups+g' /data/cups/cups-files.conf
    echo -e "--------------------------------------------------------------------------------\n"
fi
if [ ! -f /data/cups/snmp.conf ]; then
    echo -e "\n--------------------------------------------------------------------------------"
    echo "snmp.conf not found, copying default."
    echo -e "--------------------------------------------------------------------------------\n"
    cp -v /etc/cups/snmp.conf /data/cups/snmp.conf
fi

# Check for Avahi config, copy default if it doesn't exist.
if [ ! -f /data/avahi/avahi-daemon.conf ]; then
    echo -e "\n--------------------------------------------------------------------------------"
    echo "avahi-daemon.conf not found, copying default."
    echo -e "--------------------------------------------------------------------------------\n"
    cp -v /etc/avahi/avahi-daemon.conf /data/avahi/avahi-daemon.conf
fi

# Check for GCP config, make default, tell user option to make one.
if [ ! -f /data/gcp/gcp-cups-connector.config.json ]; then
    echo -e "\n--------------------------------------------------------------------------------"
    echo "gcp-cups-connector.config.json not found, generating default for local casting."
    echo -e "--------------------------------------------------------------------------------\n"
    cat > /data/gcp/gcp-cups-connector.config.json <<EOF
{
  "local_printing_enable": true,
  "cloud_printing_enable": false,
  "log_level": "INFO",
  "log_file_name": "/data/log/gcp/cloud-print-connector"
}
EOF
    echo -e "\n--------------------------------------------------------------------------------\n"
    echo -e "If you would like to generate your own config file interactively, run:\n"
    echo "docker run --rm -it -v /path/to/data:/data docquantum/cups-google-air-print gcp-connector-util --config-filename /data/gcp/gcp-cups-connector.config.json init"
    echo -e "\nto run the interactive config utility"
    echo "Documentation can be found at https://github.com/google/cloud-print-connector/wiki/Configuration"
    echo
    echo "Successful completion of the config will result in the last line being:"
    echo "The config file /data/gcp/gcp-cups-connector.config.json is ready to rock"
    echo
    echo "You may also edit the file directly."
    echo -e "\n--------------------------------------------------------------------------------\n"
else
    echo "Making sure GCP logs to '/data/log/gcp'..."
    sed -i 's+"log_file_name": "/tmp/cloud-print-connector"+"log_file_name": "/data/log/gcp/cloud-print-connector"+g' /data/gcp/gcp-cups-connector.config.json
fi