#!/bin/bash

## getting current filename and basedir
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."

##set specific vars
TEMPLATE_PATH="sag-apigw/tpl_server.yaml"
TEMPLATE_PROPS="apigw"
TEMPLATE_ENV_TYPE="default"

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
            STATUS_ID)      STATUS_ID=${VALUE} ;;
            TARGET_HOSTS)   TARGET_HOSTS=${VALUE} ;;  
            REPO_PRODUCTS)  REPO_PRODUCTS=${VALUE} ;;
            REPO_FIXES)     REPO_FIXES=${VALUE} ;;
            FIXES)          FIXES=${VALUE} ;;
            LICENSE_KEY_ALIAS_APIGW) LICENSE_KEY_ALIAS_APIGW=${VALUE} ;;
            DEFAULT_ADMIN_PASSWORD_APIGW) DEFAULT_ADMIN_PASSWORD_APIGW=${VALUE} ;;
            *)   
    esac

    ##evaluate the params for quick debugging
    eval paramValue='$'$KEY
    echo DEBUG: $KEY=$paramValue
done

### required params
if [ "x$TARGET_HOSTS" = "x" ]; then
    echo "error: variable TARGET_HOSTS is required...exiting!"
    exit 2;
fi

if [ "x$REPO_PRODUCTS" = "x" ]; then
    echo "error: variable REPO_PRODUCTS is required...exiting!"
    exit 2;
fi

if [ "x$REPO_FIXES" = "x" ]; then
    echo "error: variable REPO_FIXES is required...exiting!"
    exit 2;
fi

if [ "x$DEFAULT_ADMIN_PASSWORD_APIGW" = "x" ]; then
    echo "error: Variable DEFAULT_ADMIN_PASSWORD_APIGW is required."
    exit 2;
fi

if [ "x$LICENSE_KEY_ALIAS_APIGW" = "x" ]; then
    echo "error: Variable LICENSE_KEY_ALIAS_APIGW (for Api Gateway) is required."
    exit 2;
fi

### optional params
if [ "x$STATUS_ID" != "x" ]; then
    STATUS_ID="_$STATUS_ID"
fi

if [ "x$FIXES" = "x" ]; then
    echo "warning: variable FIXES is empty...no fixes will be applied"
    FIXES="[]"
fi

### unused
LICENSE_KEY_ALIAS_TERRACOTTA=""
TSA_URL=""

##### apply um template
$SAGCCANT_CMD -Denv.CC_CLIENT=$CC_CLIENT \
              -Dbuild.dir=$ANT_BUILD_DIR \
              -Dinstall.dir=$INSTALL_DIR \
              -Dbootstrap.install.dir=$INSTALL_DIR \
              -Dbootstrap.install.installer.version=$CC_BOOTSTRAPPER_VERSION \
              -Dbootstrap.install.installer.version.fix=$CC_BOOTSTRAPPER_VERSION_FIX \
              -Denv.SOCKET_CHECK_TARGET_HOST=$TARGET_HOSTS \
              -Denv.SOCKET_CHECK_TARGET_PORT=22 \
              -Denv.CC_TEMPLATE=$TEMPLATE_PATH \
              -Denv.CC_ENV=$TEMPLATE_PROPS \
              -Denvironment.type=$TEMPLATE_ENV_TYPE \
              -Dtarget.nodes=$TARGET_HOSTS \
              -Drepo.product=$REPO_PRODUCTS \
              -Drepo.fix=$REPO_FIXES \
              -Dfixes.apply=$FIXES \
              -Dagw.key.license.alias=$LICENSE_KEY_ALIAS_APIGW \
              -Dagw.is.instance.type=integrationServer \
              -Dagw.tsa.key.license.alias=$LICENSE_KEY_ALIAS_TERRACOTTA \
              -Dagw.tsa.url=$TSA_URL \
              -Dagw.administrator.password=$DEFAULT_ADMIN_PASSWORD_APIGW \
              setup

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