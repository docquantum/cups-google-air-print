#!/bin/bash

set -e

CUPS_USER_ADMIN=${CUPS_USER_ADMIN:-cupsgcp}
CUPS_USER_PASSWORD=${CUPS_USER_PASSWORD:-password}

if [ id "$CUPS_USER_ADMIN" >/dev/null 2>&1 ]; then
    echo "Fixing password"
    echo "${CUPS_USER_ADMIN}:${CUPS_USER_PASSWORD}" | chpasswd
    echo "Fixing group/user IDs"
else
    echo "***** Adding user & group \"${CUPS_USER_ADMIN}\" *****"
    useradd -r -d /config -s /bin/false ${CUPS_USER_ADMIN}
    usermod -a -G lpadmin ${CUPS_USER_ADMIN}
    echo "${CUPS_USER_ADMIN}:${CUPS_USER_PASSWORD}" | chpasswd
fi

echo "
-------------------------------------
GID/UID of \"$CUPS_USER_ADMIN\"
-------------------------------------"
echo "User uid:    $(id -u "$CUPS_USER_ADMIN")
User gid:    $(id -g "$CUPS_USER_ADMIN")
-------------------------------------
"