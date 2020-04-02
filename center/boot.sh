#!/bin/sh
#
# (c) 2020 Yoichi Tanibayashi
#

CMD="Nfc2BleTag.py"
LOGFILE="${HOME}/tmp/${CMD}.log"

#
# functions
#
usage () {
    echo
    echo "  usage: ${MYNAME}"
    echo
}

echo_date () {
    DATESTR=`date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "* ${DATESTR}> $*"
}

echo_do () {
    echo_date $*
    $*
    if [ $? -ne 0 ]; then
        echo_date "ERROR: ${MYNAME}: failed"
        exit 1
    fi
}

#
# main
#
echo_date "CMD=${CMD}"

MYNAME=`basename $0`
echo_date "MYNAME=${MYNAME}"

MYDIR=`dirname $0`
echo_date "MYDIR=${MYDIR}"

cd $MYDIR
BASEDIR=`pwd`
echo_date "BASEDIR=$BASEDIR"

if [ ! -z $1 ]; then
    usage
    exit 1
fi

VENVDIR=$(dirname $BASEDIR)
echo_date "VENVDIR=$VENVDIR"

BINDIR="${VENVDIR}/bin"
echo_date "BINDIR=$BINDIR"

#
# check venv and activate it
#
if [ -z ${VIRTUAL_ENV} ]; then
    ACTIVATE="${BINDIR}/activate"
    echo_date "ACTIVATE=${ACTIVATE}"

    if [ ! -f ${ACTIVATE} ]; then
        echo_date "${ACTIVATE}: no such file"
        exit 1
    fi
    . ${ACTIVATE}
fi
if [ ${VIRTUAL_ENV} != ${VENVDIR} ]; then
    echo_date "VIRTUAL_ENV=${VIRTUAL_ENV} != ${VENVDIR}"
    exit 1
fi
echo_date "VIRTUAL_ENV=${VIRTUAL_ENV}"

#
# check running
#
PID=`ps axw | grep -v grep | grep python3 | grep ${CMD} | sed 's/^ *//' | cut -d ' ' -f 1`
echo_date "PID=${PID}"

#
# restart $CMD
#
if [ ! -z ${PID} ]; then
    echo_do kill ${PID}
    echo_do sleep 2
fi

echo_date ${CMD}
${CMD} >> ${LOGFILE} 2>&1 &

echo_date "done."
