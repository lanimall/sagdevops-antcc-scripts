#!/bin/bash

## getting current filename and basedir
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."

##set specific vars
TEMPLATE_PATH_DIR="bpms"
TEMPLATE_PATH_DEFAULT="$TEMPLATE_PATH_DIR/template-content.yaml"
TEMPLATE_PROPS_DEFAULT="bpms-content"
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
    KEY=$(echo $ARGS | cut -d '=' -f 1)
    VALUE=$(echo $ARGS | cut -d '=' -f 2-)
    case "$KEY" in
            STATUS_ID)      STATUS_ID=${VALUE} ;;
            TARGET_HOSTS)   TARGET_HOSTS=${VALUE} ;;  
            TEMPLATE_PATH)          TEMPLATE_PATH=${VALUE} ;;
            TEMPLATE_PROPS)         TEMPLATE_PROPS=${VALUE} ;;
            TEMPLATE_ENV_TYPE)      TEMPLATE_ENV_TYPE=${VALUE} ;;

            is_target_um_url)          is_target_um_url=${VALUE} ;;
            is_target_um_jndi_cf)      is_target_um_jndi_cf=${VALUE} ;;
            is_um_client_prefix)          is_um_client_prefix=${VALUE} ;;

            is_endpoint_local_host)          is_endpoint_local_host=${VALUE} ;;
            is_endpoint_local_port)          is_endpoint_local_port=${VALUE} ;;

            watt_server_auth_samlResolver_host)       watt_server_auth_samlResolver_host=${VALUE} ;;
            watt_server_auth_samlResolver_port)       watt_server_auth_samlResolver_port=${VALUE} ;;

            is_adapter_jdbc_connection1_host)         is_adapter_jdbc_connection1_host=${VALUE} ;;
            is_adapter_jdbc_connection1_port)         is_adapter_jdbc_connection1_port=${VALUE} ;; 
            is_adapter_jdbc_connection1_user)         is_adapter_jdbc_connection1_user=${VALUE} ;;
            is_adapter_jdbc_connection1_password)     is_adapter_jdbc_connection1_password=${VALUE} ;;
            is_adapter_jdbc_connection1_sid)          is_adapter_jdbc_connection1_sid=${VALUE} ;;

            is_jdbc_pool_wmopt_db_type)       is_jdbc_pool_wmopt_db_type=${VALUE} ;;
            is_jdbc_pool_wmopt_db_host)       is_jdbc_pool_wmopt_db_host=${VALUE} ;;
            is_jdbc_pool_wmopt_db_port)       is_jdbc_pool_wmopt_db_port=${VALUE} ;;
            is_jdbc_pool_wmopt_db_sid)       is_jdbc_pool_wmopt_db_sid=${VALUE} ;;
            is_jdbc_pool_wmopt_db_user)       is_jdbc_pool_wmopt_db_user=${VALUE} ;;
            is_jdbc_pool_wmopt_db_password)   is_jdbc_pool_wmopt_db_password=${VALUE} ;;

            is_jdbc_pool_wmmws_db_type)       is_jdbc_pool_wmmws_db_type=${VALUE} ;;
            is_jdbc_pool_wmmws_db_host)       is_jdbc_pool_wmmws_db_host=${VALUE} ;;
            is_jdbc_pool_wmmws_db_port)       is_jdbc_pool_wmmws_db_port=${VALUE} ;;
            is_jdbc_pool_wmmws_db_sid)       is_jdbc_pool_wmmws_db_sid=${VALUE} ;;
            is_jdbc_pool_wmmws_db_user)       is_jdbc_pool_wmmws_db_user=${VALUE} ;;
            is_jdbc_pool_wmmws_db_password)   is_jdbc_pool_wmmws_db_password=${VALUE} ;;

            is_jdbc_pool_wmdb_db_type)       is_jdbc_pool_wmdb_db_type=${VALUE} ;;
            is_jdbc_pool_wmdb_db_host)       is_jdbc_pool_wmdb_db_host=${VALUE} ;;
            is_jdbc_pool_wmdb_db_port)       is_jdbc_pool_wmdb_db_port=${VALUE} ;;
            is_jdbc_pool_wmdb_db_sid)       is_jdbc_pool_wmdb_db_sid=${VALUE} ;;
            is_jdbc_pool_wmdb_db_user)       is_jdbc_pool_wmdb_db_user=${VALUE} ;;
            is_jdbc_pool_wmdb_db_password)   is_jdbc_pool_wmdb_db_password=${VALUE} ;;

            *)   
    esac

    ##evaluate the params for quick debugging
    eval paramValue='$'$KEY
    echo "DEBUG: $KEY ==> $paramValue"
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

### optional params
if [ "x$STATUS_ID" != "x" ]; then
    STATUS_ID="_$STATUS_ID"
fi

##### apply template
$SAGCCANT_CMD -Denv.CC_CLIENT=$CC_CLIENT \
        -Dbuild.dir=$ANT_BUILD_DIR \
        -Dinstall.dir=$INSTALL_DIR \
        -Denv.CC_TEMPLATE=$TEMPLATE_PATH \
        -Denv.CC_ENV=$TEMPLATE_PROPS \
        -Denvironment.type=$TEMPLATE_ENV_TYPE \
        -Dtarget.nodes=$TARGET_HOSTS \
        \
        -Dis.target.um.url=${is_target_um_url} \
        -Dis.target.um.jndi.cf=${is_target_um_jndi_cf} \
        -Dis.um.client.prefix=${is_um_client_prefix} \
        -Dis.endpoint.local.host=${is_endpoint_local_host} \
        -Dis.endpoint.local.port=${is_endpoint_local_port} \
        \
        -Dis.adapter.jdbc.connection1.host=${is_adapter_jdbc_connection1_host} \
        -Dis.adapter.jdbc.connection1.port=${is_adapter_jdbc_connection1_port} \
        -Dis.adapter.jdbc.connection1.sid=${is_adapter_jdbc_connection1_sid} \
        -Dis.adapter.jdbc.connection1.user=${is_adapter_jdbc_connection1_user} \
        -Dis.adapter.jdbc.connection1.password=${is_adapter_jdbc_connection1_password} \
        -Dis.adapter.jdbc.connection1.protocol=${is_adapter_jdbc_connection1_protocol} \
        \
        -Dwatt.server.auth.samlResolver.host=${watt_server_auth_samlResolver_host} \
        -Dwatt.server.auth.samlResolver.port=${watt_server_auth_samlResolver_port} \
        \
        -Dis.jdbc.pool_wmopt.db.type=${is_jdbc_pool_wmopt_db_type} \
        -Dis.jdbc.pool_wmopt.db.host=${is_jdbc_pool_wmopt_db_host} \
        -Dis.jdbc.pool_wmopt.db.port=${is_jdbc_pool_wmopt_db_port} \
        -Dis.jdbc.pool_wmopt.db.sid=${is_jdbc_pool_wmopt_db_sid} \
        -Dis.jdbc.pool_wmopt.db.user=${is_jdbc_pool_wmopt_db_user} \
        -Dis.jdbc.pool_wmopt.db.password=${is_jdbc_pool_wmopt_db_password} \
        \
        -Dis.jdbc.pool_wmmws.db.type=${is_jdbc_pool_wmmws_db_type} \
        -Dis.jdbc.pool_wmmws.db.host=${is_jdbc_pool_wmmws_db_host} \
        -Dis.jdbc.pool_wmmws.db.port=${is_jdbc_pool_wmmws_db_port} \
        -Dis.jdbc.pool_wmmws.db.sid=${is_jdbc_pool_wmmws_db_sid} \
        -Dis.jdbc.pool_wmmws.db.user=${is_jdbc_pool_wmmws_db_user} \
        -Dis.jdbc.pool_wmmws.db.password=${is_jdbc_pool_wmmws_db_password} \
        \
        -Dis.jdbc.pool_wmdb.db.type=${is_jdbc_pool_wmdb_db_type} \
        -Dis.jdbc.pool_wmdb.db.host=${is_jdbc_pool_wmdb_db_host} \
        -Dis.jdbc.pool_wmdb.db.port=${is_jdbc_pool_wmdb_db_port} \
        -Dis.jdbc.pool_wmdb.db.sid=${is_jdbc_pool_wmdb_db_sid} \
        -Dis.jdbc.pool_wmdb.db.user=${is_jdbc_pool_wmdb_db_user} \
        -Dis.jdbc.pool_wmdb.db.password=${is_jdbc_pool_wmdb_db_password} \
        setup_noclean

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