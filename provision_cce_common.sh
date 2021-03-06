#!/bin/bash

## getting current filename and base path
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/.."

##get the params passed-in
RUN_AS_USER=$1
BOOTSTRAP_TARGET=$2

if [ "x$RUN_AS_USER" = "x" ]; then
    RUN_AS_USER="self"
fi

##become target user for install
$BASEDIR/scripts/utils/runas_cmd.sh $RUN_AS_USER "$BASEDIR/scripts/internal/$THIS_NOEXT.sh $BOOTSTRAP_TARGET ${@:3}"

runexec=$?
exit $runexec;