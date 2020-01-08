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
            CC_SAG_LICENSE_URL)   CC_SAG_LICENSE_URL=${VALUE} ;;
            CC_SAG_LICENSE_DIR)   CC_SAG_LICENSE_DIR=${VALUE} ;;
            *)   
    esac
done

### required params
if [ "x$CC_SAG_LICENSE_DIR$CC_SAG_LICENSE_URL" = "x" ]; then
    echo "error: One of the variable CC_SAG_LICENSE_URL or CC_SAG_LICENSE_DIR is required...exiting!"
    exit 2;
fi

### optional params
if [ "x$STATUS_ID" != "x" ]; then
    STATUS_ID="_$STATUS_ID"
fi

## case for directory specified
if [ "x$CC_SAG_LICENSE_DIR" != "x" ]; then
    ### validate directory exists
    if [ ! -d ${CC_SAG_LICENSE_DIR} ]; then
        echo "error: Directory $CC_SAG_LICENSE_DIR does not exist."
        exit 2;
    fi

    ##apply custom product licenses
    echo "Adding custom product licenses to Command Central from directory ${CC_SAG_LICENSE_DIR}"
    $SAGCCANT_CMD   -Dbuild.dir=$ANT_BUILD_DIR \
                    -Denv.CC_ENV=cc \
                    -Dlicenses.dir=${CC_SAG_LICENSE_DIR} \
                    register-licenses

## case for URL specified
elif [ "x$CC_SAG_LICENSE_URL" != "x" ]; then
    echo "Apply license from URL $CC_SAG_LICENSE_URL"
    $SAGCCANT_CMD  -Dbuild.dir=$ANT_BUILD_DIR \
                    -Denv.CC_ENV=cc \
                    -Dlicenses.zip.url=$CC_SAG_LICENSE_URL\
                    licenses

fi

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