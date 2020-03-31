#!/bin/sh
#
# (c) 2020 Yoichi Tanibayashi
#

#
# functions
#
usage () {
    echo
    echo "  usage: ${MYNAME} venv_dir command_line"
    echo
}

#
# main
#
MYNAME=`basename $0`

VENV_DIR=$1
if [ -z "${VENV_DIR}" ]; then
   usage
   exit 1
fi
if [ ! -d ${VENV_DIR} ]; then
    echo "ERROR: ${VENV_DIR}: no such directory"
    usage
    exit 1
fi
shift

CMDLINE=$*
if [ -z "${CMDLINE}" ]; then
    echo "ERROR: no command line"
    usage
    exit 1
fi

if [ -z "${VIRTUAL_ENV}" ]; then
    ACTIVATE_FILE="${VENV_DIR}/bin/activate"
    if [ ! -f ${ACTIVATE_FILE} ]; then
        echo "ERROR: ${ACTIVATE_FILE}: no such file"
        usage
        exit 1
    fi
    . ${VENV_DIR}/bin/activate
fi

echo "VIRTUAL_ENV=$VIRTUAL_ENV"

echo "CMDLINE=$CMDLINE"
exec $CMDLINE
