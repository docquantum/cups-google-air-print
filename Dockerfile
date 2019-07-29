FROM phusion/baseimage:0.11
LABEL MAINTAINER="Daniel Shchur (DocQuantum) <shchurgood@gmail.com>"

# Set environment variables
ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" DEBIAN_FRONTEND="noninteractive" TERM="xterm" CUPS_USER_ADMIN="cupsgcp" CUPS_USER_PASSWORD="password" DBUS=TRUE

# Install Dependencies, remove non-necessary services, gen locales
RUN \
 echo "***** Installing & updating packages *****" \
 && apt-get update \
 && apt-get upgrade -y -o Dpkg::Options::="--force-confold" \
 && apt-get install --no-install-recommends -y \
    locales \
    tzdata \
    cups \
    python \
    python-cups \
    libcups2 \
    libavahi-client3 \
    libnss-mdns \
    avahi-daemon \
    libsnmp30 \
    google-cloud-print-connector \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && echo "***** Remove unnecessary services & generate locales *****" \
 && rm -rf /etc/service/sshd /etc/service/cron /etc/my_init.d/00_regen_ssh_host_keys.sh \
 && locale-gen en_US.UTF-8

# Copy service files
COPY root/ /

# Make services executable
RUN chmod -R +x /etc/my_init.d \
 && chmod -R +x /etc/service

# Export volumes
VOLUME /data /var/run/dbus

# Use init system
CMD [ "/sbin/my_init" ]