#!/bin/bash

## getting filename without path and extension
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."

## apply global env
if [ -f ${BASEDIR}/scripts/conf/setenv_cce_globals.sh ]; then
    . ${BASEDIR}/scripts/conf/setenv_cce_globals.sh
fi

## apply globals overrides
if [ -f ${HOME}/.setenv_cce_globals.sh ]; then
    . ${HOME}/.setenv_cce_globals.sh
fi

## apply cce env
if [ -f ${HOME}/setenv-cce.sh ]; then
    . ${HOME}/setenv-cce.sh
fi


### get the args
for ARGS in "$@"
do
    KEY=$(echo $ARGS | cut -f1 -d=)
    VALUE=$(echo $ARGS | cut -f2 -d=)
    case "$KEY" in
            STATUS_ID)          STATUS_ID=${VALUE} ;;
            CC_SAG_IMAGE_DIR)   CC_SAG_IMAGE_DIR=${VALUE} ;;
            CC_SAG_IMAGE_ACTION)   CC_SAG_IMAGE_ACTION=${VALUE} ;;
            *)   
    esac
done

## print params for simple debugging
echo STATUS_ID=$STATUS_ID
echo CC_SAG_IMAGE_DIR=$CC_SAG_IMAGE_DIR
echo CC_SAG_IMAGE_ACTION=$CC_SAG_IMAGE_ACTION

### required params
if [ "x$CC_SAG_IMAGE_DIR" = "x" ]; then
    echo "error: variable CC_SAG_IMAGE_DIR is required...exiting!"
    exit 2;
fi

if [ "x$CC_SAG_IMAGE_ACTION" = "x" ]; then
    echo "error: variable CC_SAG_IMAGE_ACTION is required (either 'upload' or 'register')...exiting!"
    exit 2;
fi

### optional params
if [ "x$STATUS_ID" != "x" ]; then
    STATUS_ID="_$STATUS_ID"
fi

echo "Installing all the product/fix images located in $CC_SAG_IMAGE_DIR"
$SAGCCANT_CMD   -Dbuild.dir=$ANT_BUILD_DIR \
                -Denv.CC_ENV=cc \
                -Dimages.dir=$CC_SAG_IMAGE_DIR \
                $CC_SAG_IMAGE_ACTION-images

runexec=$?
if [ $runexec -eq 0 ]; then
    echo "[$THIS_NOEXT: SUCCESS]"
    
    ##create/update a file in tmp to broadcast that the script is done
    touch ${HOME}/$THIS_NOEXT.status.success$STATUS_ID
else
    echo "[$THIS_NOEXT: FAIL]"
    
    ##create/update a file in tmp to broadcast that the script is done
    touch ${HOME}/$THIS_NOEXT.status.fail$STATUS_ID
fi

exit $runexec;