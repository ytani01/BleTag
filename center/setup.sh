#!/bin/sh
#
# (c) 2020 Yoichi Tanibayashi
#

BINFILES="activate-do.sh MyLogger.py"
BINFILES="${BINFILES} Nfc2BleTag.py boot-Nfc2BleTag.sh"
BINFILES="${BINFILES} BleTagPublisher.py BlePeripheral.py"
BINFILES="${BINFILES} get-tagid.py"

#
# functions
#
usage () {
    echo
    echo "  usage: ${MYNAME}"
    echo
}

ts_echo () {
    DATESTR=`date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "* ${DATESTR}> $*"
}

ts_echo_do () {
    ts_echo $*
    $*
    if [ $? -ne 0 ]; then
        ts_echo "ERROR: ${MYNAME}: failed"
        exit 1
    fi
}

#
# main
#
MYNAME=`basename $0`
ts_echo "MYNAME=${MYNAME}"

MYDIR=`dirname $0`
ts_echo "MYDIR=${MYDIR}"

cd $MYDIR
BASEDIR=`pwd`
ts_echo "BASEDIR=$BASEDIR"

if [ ! -z $1 ]; then
    usage
    exit 1
fi

VENVDIR=$(dirname $(dirname $BASEDIR))
ts_echo "VENVDIR=$VENVDIR"

BINDIR="${VENVDIR}/bin"
ts_echo "BINDIR=$BINDIR"

#
# check venv and activate it
#
if [ -z ${VIRTUAL_ENV} ]; then
    ACTIVATE="${BINDIR}/activate"
    ts_echo "ACTIVATE=${ACTIVATE}"

    if [ ! -f ${ACTIVATE} ]; then
        ts_echo "${ACTIVATE}: no such file"
        exit 1
    fi
    . ${ACTIVATE}
fi
if [ ${VIRTUAL_ENV} != ${VENVDIR} ]; then
    ts_echo "VIRTUAL_ENV=${VIRTUAL_ENV} != ${VENVDIR}"
    exit 1
fi
ts_echo "VIRTUAL_ENV=${VIRTUAL_ENV}"

#
# download other repositoris
#
ts_echo_do cd ${VENVDIR}
for g in BleBeacon NFC Templates; do
    if [ ! -d $g ]; then
        ts_echo_do git clone git@github.com:ytani01/${g}.git
    fi
done

#
# update pip
#
ts_echo_do python3 -m pip install -U pip
hash -r
pip -V

#
# install Python packages
#
ts_echo_do cd ${BASEDIR}
ts_echo_do pip install -r requirements.txt

#
# setcap
#
ts_echo_do sudo setcap 'cap_net_raw,cap_net_admin+eip' $(readlink -f $(which python3))
ts_echo_do sudo setcap 'cap_net_raw,cap_net_admin+eip' ${VENVDIR}/lib/python3.?/site-packages/bluepy/bluepy-helper

#
# make symbolick links
#
for f in ${BINFILES}; do
    ts_echo_do ln -sf ${BASEDIR}/${f} ${BINDIR}
done

ts_echo_do ln -sf ${VENVDIR}/lib/python3.*/site-packages/bluepy/bluepy-helper ${BINDIR}

ts_echo "done."
