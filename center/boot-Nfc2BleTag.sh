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
ts_echo "CMD=${CMD}"

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

VENVDIR=$(dirname $BASEDIR)
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
# check running
#
PID=`ps axw | grep -v grep | grep python3 | grep ${CMD} | sed 's/^ *//' | cut -d ' ' -f 1 | sed 's/\n/ /g'`
ts_echo "PID=${PID}"

#
# restart $CMD
#
if [ ! -z "${PID}" ]; then
    for p in ${PID}; do
        ts_echo_do kill $p
    done
    ts_echo_do sleep 1
fi

ts_echo ${CMD}
${CMD} >> ${LOGFILE} 2>&1 &

ts_echo "done."
