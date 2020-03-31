#!/bin/sh
#
# (c) 2020 Yoichi Tanibayashi
#
usage () {
    echo "usage: ${MYNAME}"
}

echo_date () {
    DATESTR=`date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${DATESTR}> $*"
}

echo_do () {
    echo_date $*
    eval $*
}

MYNAME=`basename $0`
echo_date "MYNAME=${MYNAME}"

BINFILES="center/TagPublisher.py center/BlePeripheral.py center/MyLogger.py"

MYDIR=`dirname $0`
echo_date "MYDIR=${MYDIR}"

cd $MYDIR
BASEDIR=`pwd`
echo_date "BASEDIR=$BASEDIR"

VENVDIR=`dirname $BASEDIR`
echo_date "VENVDIR=$VENVDIR"

BINDIR="${VENVDIR}/bin"
echo_date "BINDIR=$BINDIR"

#
# check venv
#
if [ -z ${VIRTUAL_ENV} ]; then
    ACTIVATE="../bin/activate"
    if [ ! -f ${ACTIVATE} ]; then
        echo_date "${ACTIVATE}: no such file"
        exit 1
    fi
    . ../bin/activate
fi
if [ ${VIRTUAL_ENV} != ${VENVDIR} ]; then
    echo_date "VIRTUAL_ENV=${VIRTUAL_ENV} != ${VENVDIR}"
    exit 1
fi

#
# setcap
#
echo_date "* setcap"
echo_do sudo setcap 'cap_net_raw,cap_net_admin+eip' $(readlink -f $(which python3))

#
# copy files
#
echo_date "* copy files"
echo_do cp -vf ${BINFILES} ${BINDIR}
