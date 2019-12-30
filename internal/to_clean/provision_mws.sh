#!/bin/bash

## getting current filename and basedir
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."

##set specific vars
TEMPLATE_PATH_DEFAULT="sag-mws/template-base.yaml"
TEMPLATE_PROPS_DEFAULT="mws-base"
TEMPLATE_ENV_TYPE_DEFAULT="default"

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
            TEMPLATE_PATH)          TEMPLATE_PATH=${VALUE} ;;
            TEMPLATE_PROPS)         TEMPLATE_PROPS=${VALUE} ;;
            TEMPLATE_ENV_TYPE)      TEMPLATE_ENV_TYPE=${VALUE} ;;
            FIXES)          FIXES=${VALUE} ;;
            REPO_PRODUCTS)  REPO_PRODUCTS=${VALUE} ;;
            REPO_FIXES)     REPO_FIXES=${VALUE} ;;

            mws_lb_host)                mws_lb_host=${VALUE} ;;
            mws_lb_http_port)           mws_lb_http_port=${VALUE} ;;
            mws_lb_https_port)          mws_lb_https_port=${VALUE} ;;
            
            db_type)                db_type=${VALUE} ;;
            db_host)                db_host=${VALUE} ;;
            db_port)                db_port=${VALUE} ;;
            db_sid)                 db_sid=${VALUE} ;;
            db_username)            db_username=${VALUE} ;;
            db_password)            db_password=${VALUE} ;;
            *)   
    esac

    ##evaluate the params for quick debugging
    eval paramValue='$'$KEY
    echo DEBUG: $KEY=$paramValue
done

##set specific vars
if [ "x$TEMPLATE_PATH" = "x" ]; then
    echo "warning: variable TEMPLATE_PATH is empty...defaulting"
    TEMPLATE_PATH=$TEMPLATE_PATH_DEFAULT
fi

if [ "x$TEMPLATE_PROPS" = "x" ]; then
    echo "warning: variable TEMPLATE_PROPS is empty...defaulting"
    TEMPLATE_PROPS=$TEMPLATE_PROPS_DEFAULT
fi

if [ "x$TEMPLATE_ENV_TYPE" = "x" ]; then
    echo "warning: variable TEMPLATE_ENV_TYPE is empty...defaulting"
    TEMPLATE_ENV_TYPE=$TEMPLATE_ENV_TYPE_DEFAULT
fi

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

if [ "x$DEFAULT_ADMIN_PASSWORD" = "x" ]; then
    echo "error: Variable DEFAULT_ADMIN_PASSWORD is required...exiting!"
    exit 2;
fi

if [ "x$db_type" = "x" ] ||
   [ "x$db_host" = "x" ] ||
   [ "x$db_port" = "x" ] ||
   [ "x$db_sid" = "x" ] ||
   [ "x$db_username" = "x" ] ||
   [ "x$db_password" = "x" ]; then
    echo "error: some required database variables are missing...exiting!"
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

##### apply template
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
              -Dmws.fixes=$FIXES \
              -Dmws.lb.host=${mws_lb_host} \
              -Dmws.lb.http.port=${mws_lb_http_port} \
              -Dmws.lb.https.port=${mws_lb_https_port} \
              -Ddb.type=${db_type} \
              -Ddb.host=${db_host} \
              -Ddb.port=${db_port} \
              -Ddb.sid=${db_sid} \
              -Ddb.username=${db_username} \
              -Ddb.password=${db_password} \
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