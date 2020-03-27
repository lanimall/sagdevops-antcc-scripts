#!/bin/bash

## getting current filename and base path
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."

##get the params passed-in
CONFIG_ITEM=$1

function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
#function join_by { local IFS="$1"; shift; echo "$*"; }

## build an array of allowed names
configitems=()
for f in $THISDIR/configure_*; do
  filename=$(basename $f)
  filename_noext="${filename%.*}"
  configitems_toadd=$(echo $filename_noext | sed "s/configure_//")
  configitems+=( $configitems_toadd );
done

# check if arr contains value
if [[ " ${configitems[@]} " =~ " ${CONFIG_ITEM} " ]]; then
    echo "Variable CONFIG_ITEM=$CONFIG_ITEM is valid!"
fi

# check if arr does not contains value
if [[ ! " ${configitems[@]} " =~ " ${CONFIG_ITEM} " ]]; then
    # whatever you want to do when arr doesn't contain value
    valid_values=$(join_by ' , ' ${configitems[@]})
    echo "error: variable CONFIG_ITEM is not valid. Valid values are: $valid_values"
    exit 2;
fi

## build stack target file name and check if exists
CONFIG_ITEM_SCRIPT_FILE_NOEXT="configure_$CONFIG_ITEM"
if [ ! -f $BASEDIR/scripts/internal/$CONFIG_ITEM_SCRIPT_FILE_NOEXT.sh ]; then
    echo "$CONFIG_ITEM_SCRIPT_FILE_NOEXT.sh does not exist...exiting"
    exit 2;
fi

##call install script
exec $BASEDIR/scripts/internal/$CONFIG_ITEM_SCRIPT_FILE_NOEXT.sh "${@:2}"

runexec=$?
exit $runexec