#!/bin/bash

## getting current filename and basedir
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."

##set specific vars
TEMPLATE_PATH_DIR="bpms"
TEMPLATE_PATH_DEFAULT="$TEMPLATE_PATH_DIR/template-base.yaml"
TEMPLATE_PROPS_DEFAULT="bpms-base"
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
            REPO_PRODUCTS)  REPO_PRODUCTS=${VALUE} ;;
            REPO_FIXES)     REPO_FIXES=${VALUE} ;;
            FIXES)          FIXES=${VALUE} ;;
            APPLY_FIXES_ONLY)      APPLY_FIXES_ONLY=${VALUE} ;;
            
            LICENSE_KEY_ALIAS_IS) LICENSE_KEY_ALIAS_IS=${VALUE} ;;
            LICENSE_KEY_ALIAS_TC) LICENSE_KEY_ALIAS_TC=${VALUE} ;;
            LICENSE_KEY_ALIAS_RULES) LICENSE_KEY_ALIAS_RULES=${VALUE} ;;
            
            DEFAULT_ADMIN_PASSWORD) DEFAULT_ADMIN_PASSWORD=${VALUE} ;;
            
            is_jdbc_pool_wmis_db_type)       is_jdbc_pool_wmis_db_type=${VALUE} ;;
            is_jdbc_pool_wmis_db_host)       is_jdbc_pool_wmis_db_host=${VALUE} ;;
            is_jdbc_pool_wmis_db_port)       is_jdbc_pool_wmis_db_port=${VALUE} ;;
            is_jdbc_pool_wmis_db_sid)       is_jdbc_pool_wmis_db_sid=${VALUE} ;;
            is_jdbc_pool_wmis_db_user)       is_jdbc_pool_wmis_db_user=${VALUE} ;;
            is_jdbc_pool_wmis_db_password)   is_jdbc_pool_wmis_db_password=${VALUE} ;;

            is_jdbc_pool_wmbpm_db_type)       is_jdbc_pool_wmbpm_db_type=${VALUE} ;;
            is_jdbc_pool_wmbpm_db_host)       is_jdbc_pool_wmbpm_db_host=${VALUE} ;;
            is_jdbc_pool_wmbpm_db_port)       is_jdbc_pool_wmbpm_db_port=${VALUE} ;;
            is_jdbc_pool_wmbpm_db_sid)       is_jdbc_pool_wmbpm_db_sid=${VALUE} ;;
            is_jdbc_pool_wmbpm_db_user)       is_jdbc_pool_wmbpm_db_user=${VALUE} ;;
            is_jdbc_pool_wmbpm_db_password)   is_jdbc_pool_wmbpm_db_password=${VALUE} ;;

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

### optional params
if [ "x$STATUS_ID" != "x" ]; then
    STATUS_ID="_$STATUS_ID"
fi

if [ "$APPLY_FIXES_ONLY" = "true" ]; then
    TEMPLATE_PATH=$TEMPLATE_PATH_DIR/template-fixes.yaml
    TEMPLATE_PROPS=fixes
    TEMPLATE_ENV_TYPE=$TEMPLATE_ENV_TYPE_DEFAULT

    if [ "x$FIXES" = "x" ]; then
        echo "error: variable FIXES is required...exiting!"
        exit 2;
    fi

    ##### apply template
    $SAGCCANT_CMD -Denv.CC_CLIENT=$CC_CLIENT \
        -Dbuild.dir=$ANT_BUILD_DIR \
        -Dinstall.dir=$INSTALL_DIR \
        -Dbootstrap.install.dir=$INSTALL_DIR \
        -Dbootstrap.install.installer.version=$CC_BOOTSTRAPPER_VERSION \
        -Dbootstrap.install.installer.version.fix=$CC_BOOTSTRAPPER_VERSION_FIX \
        -Denv.CC_TEMPLATE=$TEMPLATE_PATH \
        -Denv.CC_ENV=$TEMPLATE_PROPS \
        -Denvironment.type=$TEMPLATE_ENV_TYPE \
        -Drepo.product=$REPO_PRODUCTS \
        -Drepo.fix=$REPO_FIXES \
        -Dtarget.nodes=$TARGET_HOSTS \
        -Dproducts.fixes=$FIXES \
        setup

else
    if [ "x$DEFAULT_ADMIN_PASSWORD" = "x" ]; then
        echo "error: Variable DEFAULT_ADMIN_PASSWORD is required...exiting!"
        exit 2;
    fi

    if  [ "x$is_jdbc_pool_wmis_db_type" = "x" ] ||
        [ "x$is_jdbc_pool_wmis_db_host" = "x" ] ||
        [ "x$is_jdbc_pool_wmis_db_port" = "x" ] ||
        [ "x$is_jdbc_pool_wmis_db_sid" = "x" ] ||
        [ "x$is_jdbc_pool_wmis_db_user" = "x" ] ||
        [ "x$is_jdbc_pool_wmis_db_password" = "x" ]; then
        echo "error: some required database variables are missing...exiting!"
        exit 2;
    fi

    if  [ "x$is_jdbc_pool_wmbpm_db_type" = "x" ] ||
        [ "x$is_jdbc_pool_wmbpm_db_host" = "x" ] ||
        [ "x$is_jdbc_pool_wmbpm_db_port" = "x" ] ||
        [ "x$is_jdbc_pool_wmbpm_db_sid" = "x" ] ||
        [ "x$is_jdbc_pool_wmbpm_db_user" = "x" ] ||
        [ "x$is_jdbc_pool_wmbpm_db_password" = "x" ]; then
        echo "error: some required database variables are missing...exiting!"
        exit 2;
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
        -Dis.fixes=$FIXES \
        -Dis.key.license.alias=$LICENSE_KEY_ALIAS_IS \
        -Dtc.key.license.alias=$LICENSE_KEY_ALIAS_TC \
        -Drules.key.license.alias=$LICENSE_KEY_ALIAS_RULES \
        -Dis.administrator.password=$DEFAULT_ADMIN_PASSWORD \
        -Dis.jdbc.pool_wmis.db.type=${is_jdbc_pool_wmis_db_type} \
        -Dis.jdbc.pool_wmis.db.host=${is_jdbc_pool_wmis_db_host} \
        -Dis.jdbc.pool_wmis.db.port=${is_jdbc_pool_wmis_db_port} \
        -Dis.jdbc.pool_wmis.db.sid=${is_jdbc_pool_wmis_db_sid} \
        -Dis.jdbc.pool_wmis.db.user=${is_jdbc_pool_wmis_db_user} \
        -Dis.jdbc.pool_wmis.db.password=${is_jdbc_pool_wmis_db_password} \
        -Dis.jdbc.pool_wmbpm.db.type=${is_jdbc_pool_wmbpm_db_type} \
        -Dis.jdbc.pool_wmbpm.db.host=${is_jdbc_pool_wmbpm_db_host} \
        -Dis.jdbc.pool_wmbpm.db.port=${is_jdbc_pool_wmbpm_db_port} \
        -Dis.jdbc.pool_wmbpm.db.sid=${is_jdbc_pool_wmbpm_db_sid} \
        -Dis.jdbc.pool_wmbpm.db.user=${is_jdbc_pool_wmbpm_db_user} \
        -Dis.jdbc.pool_wmbpm.db.password=${is_jdbc_pool_wmbpm_db_password} \
        setup_noclean
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