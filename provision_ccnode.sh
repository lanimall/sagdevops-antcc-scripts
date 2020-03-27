#!/bin/bash

## getting base dir
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/.."

##get the params passed-in
RUN_AS_USER=$1

if [ "x$RUN_AS_USER" = "x" ]; then
    RUN_AS_USER="self"
fi

$BASEDIR/scripts/provision_cce_common.sh $RUN_AS_USER agent "${@:2}"