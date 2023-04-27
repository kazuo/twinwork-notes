#!/usr/bin/env sh

BASE_PKGS=
BASE_PKGS="${BASE_PKGS} security/ca_root_nss"
BASE_PKGS="${BASE_PKGS} devel/nasm"
BASE_PKGS="${BASE_PKGS} sysutils/screen"
BASE_PKGS="${BASE_PKGS} shells/bash"
BASE_PKGS="${BASE_PKGS} shells/zsh"
BASE_PKGS="${BASE_PKGS} misc/gnuls"
BASE_PKGS="${BASE_PKGS} security/sudo"
BASE_PKGS="${BASE_PKGS} editors/vim"
BASE_PKGS="${BASE_PKGS} devel/git@lite"
BASE_PKGS="${BASE_PKGS} net/rsync"

# optional additional packages
ADD_PKGS=
ADD_PKGS="${ADD_PKGS=} net/py-speedtest-cli"
ADD_PKGS="${ADD_PKGS=} sysutils/smartmontools"
ADD_PKGS="${ADD_PKGS=} mail/ssmtp"
ADD_PKGS="${ADD_PKGS=} sysutils/renameutils"
ADD_PKGS="${ADD_PKGS=} security/py-certbot"
ADD_PKGS="${ADD_PKGS=} security/gnupg"
ADD_PKGS="${ADD_PKGS=} net/avahi-app"
ADD_PKGS="${ADD_PKGS=} net/samba413"
ADD_PKGS="${ADD_PKGS=} security/py-yubikey-manager

FEPP_PKGS=""
# nginx, pgsql, php81
FEPP_PKGS="${FEPP_PKGS} www/nginx"
FEPP_PKGS="${FEPP_PKGS} databases/postgresql14-client"
FEPP_PKGS="${FEPP_PKGS} databases/postgresql14-server"
FEPP_PKGS="${FEPP_PKGS} lang/php81"

# default php81-extensions (i.e. /usr/ports/lang/php81-extensions/)
FEPP_PKGS="${FEPP_PKGS} textproc/php81-ctype"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-dom"
FEPP_PKGS="${FEPP_PKGS} security/php81-filter"
FEPP_PKGS="${FEPP_PKGS} converters/php81-iconv"
FEPP_PKGS="${FEPP_PKGS} www/php81-opcache"
FEPP_PKGS="${FEPP_PKGS} databases/php81-pdo"
FEPP_PKGS="${FEPP_PKGS} archivers/php81-phar"
FEPP_PKGS="${FEPP_PKGS} sysutils/php81-posix"
FEPP_PKGS="${FEPP_PKGS} www/php81-session"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-simplexml"
FEPP_PKGS="${FEPP_PKGS} databases/php81-sqlite3"
FEPP_PKGS="${FEPP_PKGS} databases/php81-pdo_sqlite"
FEPP_PKGS="${FEPP_PKGS} devel/php81-tokenizer"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-xml"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-xmlreader"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-xmlwriter"

# php81 pgsql extensions
FEPP_PKGS="${FEPP_PKGS} databases/php81-pgsql"
FEPP_PKGS="${FEPP_PKGS} databases/php81-pdo_pgsql"

# other php81 extensions
FEPP_PKGS="${FEPP_PKGS} archivers/php81-bz2"
FEPP_PKGS="${FEPP_PKGS} ftp/php81-curl"
FEPP_PKGS="${FEPP_PKGS} graphics/php81-exif"
FEPP_PKGS="${FEPP_PKGS} graphics/php81-gd"
FEPP_PKGS="${FEPP_PKGS} devel/php81-intl"
FEPP_PKGS="${FEPP_PKGS} converters/php81-mbstring"
FEPP_PKGS="${FEPP_PKGS} archivers/php81-zip"
FEPP_PKGS="${FEPP_PKGS} archivers/php81-zlib"

# other php81 extensions recommended for nextcloud
FEPP_PKGS="${FEPP_PKGS} sysutils/php81-fileinfo"
FEPP_PKGS="${FEPP_PKGS} graphics/pecl-imagick"
FEPP_PKGS="${FEPP_PKGS} ftp/php81-ftp"
FEPP_PKGS="${FEPP_PKGS} math/php81-bcmath"
FEPP_PKGS="${FEPP_PKGS} math/php81-gmp"
FEPP_PKGS="${FEPP_PKGS} devel/php81-pcntl"
FEPP_PKGS="${FEPP_PKGS} net/php81-ldap"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-xsl"

OPEN_PKGS=""
OPEN_PKGS="${OPEN_PKGS} net/openntpd"
OPEN_PKGS="${OPEN_PKGS} security/openssh-portable"
OPEN_PKGS="${OPEN_PKGS} security/libressl"

continue_prompt() {
    local MESSAGE=$1

    echo ""
    echo ${MESSAGE}
    read -p "Continue? [y/N] " yn
    case $yn in
        [Yy]*)
            ;;
        *)
            echo "Canceling operation..."
            exit 1
            ;;
    esac
}

add_poudriere_pkg_file() {
    local PKGS=$@
    if [ -z ${PKGS+x} ] || [ "${PKGS}" == "" ]; then
        echo "PKGS not set"
        exit 1
    fi

    touch ${POUDRIERE_PKG_FILE}
    for PORT in ${PKGS}; do
        if grep -qx "${PORT}" ${POUDRIERE_PKG_FILE}; then
            continue
        fi

        if test "${PKG#*@}" != "$PKG"; then
            # no idea why poudriere bulk won't abide by specified flavor, so we just
            # install the main package and hope the make.conf sets the flavor for it
            PORT=$( printf "devel/git@lite" | sed "s/^.*\///" | sed "s/@.*$//" )
        fi        
        
        echo ${PORT} | tee -a ${POUDRIERE_PKG_FILE}
    done    
}

install_from_pkg() {
    local PKGS=$@
    if [ -z ${PKGS+x} ] || [ "${PKGS}" == "" ]; then
        echo "PKGS not set"
        exit 1
    fi

    pkg update    
    for PKG in ${PKGS}; do
        if test "${PKG#*@}" != "$PKG"; then
            # oddly flavors can't be installed as its native name: i.e. devel/git@lite, instead
            # pkg prefers it as git-lite... this ensures flavors can be installed
            PKG=$( printf $PKG | sed "s/^.*\///" | sed "s/@/-/" )
        fi
        pkg install -y ${PKG}
    done

    pkg clean
}

build_poudriere() {
    local PKGS=$@

    if [ -z ${POUDRIERE_JAIL_NAME+x} ] || [ "${POUDRIERE_JAIL_NAME}" == "" ]; then
        echo "POUDRIERE_JAIL_NAME and/or POUDRIERE_JAIL_VERSION is not set!" 
        exit 1
    fi    

    if [ -z ${PKGS+x} ] || [ "${PKGS}" == "" ]; then
        echo "PKGS not set"
        exit 1
    fi
    poudriere bulk -j ${POUDRIERE_JAIL_NAME} -p default ${PKGS}
}

setup_poudriere_base() {
    local CMD_STATUS=

    if [ -z ${POUDRIERE_JAIL_NAME+x} ] || [ "${POUDRIERE_JAIL_NAME}" == "" ] || \
        [ -z ${POUDRIERE_JAIL_VERSION+x} ] || [ "${POUDRIERE_JAIL_VERSION}" == "" ]; then

        echo "POUDRIERE_JAIL_NAME and/or POUDRIERE_JAIL_VERSION is not set!" 
        exit 1
    fi

    if command -v poudriere &> /dev/null && test -f /usr/local/etc/poudriere.d/make.conf; then
        echo "Detected poudriere has already been setup"
        exit
    fi 

    # defaults ports dir: /usr/local/poudriere/ports/default
    # to check for pkg update:
    # PORTSDIR=/usr/local/poudriere/ports/default pkg version -P -l "<"

    pkg install -y ports-mgmt/poudriere && \

    # requires ZPOOL to be set
    sysrc -f /usr/local/etc/poudriere.conf ZPOOL=zroot && \
    poudriere jail -c -j ${POUDRIERE_JAIL_NAME} -v ${POUDRIERE_JAIL_VERSION} && \
    mkdir -vp /usr/local/etc/pkg/repos

    # default DISTFILES_CACHE set in poudriere.conf
    mkdir -vp /usr/ports/distfiles

    CMD_STATUS=$?

    if [ -z ${CMD_STATUS} ]; then
        exit 1
    fi

    cat > /usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
# Ensures that Poudriere will always be used for pkg
FreeBSD: {
    enabled: no,
}
EOF

    cat > /usr/local/etc/pkg/repos/Poudriere.conf <<EOF
Poudriere: {
    url: "file:///usr/local/poudriere/data/packages/${POUDRIERE_JAIL_NAME}-default",
    enabled: yes,
    priority: 100,
}
EOF

    cat > /usr/local/etc/poudriere.d/make.conf <<EOF
# https://cgit.freebsd.org/ports/tree/Mk/bsd.default-versions.mk
DEFAULT_VERSIONS+=python=3.9 python3=3.9
DEFAULT_VERSIONS+=pgsql=14
DEFAULT_VERSIONS+=php=8.1
DEFAULT_VERSIONS+=samba=4.13
# MariaDB 10.5
#DEFAULT_VERSIONS+=mysql=10.5m

OPTIONS_UNSET=ALSA CUPS DEBUG DOCBOOK DOCS EXAMPLES FONTCONFIG HTMLDOCS PROFILE TESTS X11

.if \${.CURDIR:C/.*\/devel\/git//} == ""
FLAVOR=lite
.endif
EOF

    echo "Check poudriere make options in /usr/local/etc/poudriere.d/make.conf"
}

setup_poudriere_ports() {
    if test -f /usr/local/poudriere/ports/default; then
        echo "Detected default poudriere ports already created"
        exit
    fi

    if ! command -v git &> /dev/null; then
        pkg install -y git-lite
    fi
    
    poudriere ports -c
}

use_loki() {
    local MASTER_NAME="${POUDRIERE_JAIL_NAME}-default"
    local FBSD_VERSION=`uname -U`    
    LOKI_DOMAIN=loki.twinwork.net
    LOKI_IP=$(host ${LOKI_DOMAIN} | awk '{ print $4 }')
    LOKI_CONF="/usr/local/etc/pkg/repos/Loki.conf"
    CURRENT_IP=$(host myip.opendns.com resolver1.opendns.com | tail -1 | awk '{ print $4 }')
    echo "Your public IP: ${CURRENT_IP}"
    echo "Loki's IP ${LOKI_IP}"    
    
    if test -f ${LOKI_CONF}; then
        echo "${LOKI_CONF} already configured"
        exit
    fi
    
    if [ "${LOKI_IP}" == "$CURRENT_IP" ]; then
        # get around weird nginx reverse proxy 
        # issues while on the same network
        echo "Detected Loki on local network, adding ${LOKI_DOMAIN} to /etc/hosts"
        echo "192.168.1.201 loki.twinwork.net" | tee -a /etc/hosts
    fi

    if [ ${POUDRIERE_SET} ]; then
        MASTER_NAME="${MASTER_NAME}-${POUDRIERE_SET}"
    fi

    mkdir -vp /usr/local/etc/pkg/repos
    mkdir -vp /usr/local/etc/ssl/certs
    cp -v ${DIR}/loki-poudriere.cert /usr/local/etc/ssl/certs/    

    if test -f /usr/local/etc/pkg/repos/Poudriere.conf; then
        sed -e '/enabled: / s/yes/no/' -i '' /usr/local/etc/pkg/repos/Poudriere.conf
    fi

    disable_freebsd_repo

    if [ "${FBSD_VERSION}" -lt 1301000 ]; then
        # remove sign check for versions older than 13.1-RELEASE
        cat > "${LOKI_CONF}" <<EOF
Loki: {
    url: "pkg+https://${LOKI_DOMAIN}/poudriere/packages/${MASTER_NAME}",
    mirror_type: "srv",
    enabled: yes,
    priority: 1000,
}
EOF
    else
        cat > "${LOKI_CONF}" <<EOF
Loki: {
    url: "pkg+https://${LOKI_DOMAIN}/poudriere/packages/${MASTER_NAME}",
    mirror_type: "srv",
    signature_type: "pubkey",
    pubkey: "/usr/local/etc/ssl/certs/loki-poudriere.cert",
    enabled: yes,
    priority: 1000,
}
EOF
    fi    

    echo "Added Loki repo in ${LOKI_CONF}"
}

use_open() {
    # disable FreeBSD defaults
    sysrc sshd_enable=NO
    sysrc ntpd_enable=NO
    sysrc ntpdate_enable=NO

    sysrc openssh_enable=YES
    sysrc openntpd_enable=YES
}

disable_freebsd_repo() {

    if test -f /usr/local/etc/pkg/repos/FreeBSD.conf; then
        echo "/usr/local/etc/pkg/repos/FreeBSD.conf already configured"
        exit
    fi
    
    mkdir -vp /usr/local/etc/pkg/repos
    cat > /usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
# Ensures that Poudriere will always be used for pkg
FreeBSD: {
    enabled: no,
}
EOF
}