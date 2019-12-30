#!/bin/bash

## getting current filename and basedir
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."
DEBUG=true

SAGCCANT_TEMPLATE_PARAMS=""
mandatory_args=("template.path" "template.props" "target.nodes" "repo.product" "repo.fix")
optional_args=("environment.type=default" "fixes=[]")
script_arg_keys=()

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

### get the args that should be in the format: 'somekey1=somevalue1' 'somekey2=somevalue2'
for script_arg in "$@"
do
    arg_key=$(echo $script_arg | cut -d '=' -f 1)
    arg_value=$(echo $script_arg | cut -d '=' -f 2-)
    
    ##print the params for debugging (temp)
    if [ $DEBUG == true ]; then
        echo "DEBUG: $arg_key ==> $arg_value"
    fi

    if [ "x$arg_key" != "x" ]; then
        script_arg_keys+=( $arg_key );
        case "$arg_key" in
                STATUS_ID)          STATUS_ID=${arg_value} ;;
                template.path)      SAGCCANT_TEMPLATE_PARAMS="$SAGCCANT_TEMPLATE_PARAMS -Denv.CC_TEMPLATE=${arg_value}" ;;
                template.props)     SAGCCANT_TEMPLATE_PARAMS="$SAGCCANT_TEMPLATE_PARAMS -Denv.CC_ENV=${arg_value}" ;;
                *) SAGCCANT_TEMPLATE_PARAMS="$SAGCCANT_TEMPLATE_PARAMS -D$arg_key=$arg_value" ;;
        esac
    fi
done

# Mandatory params: check if key was not provided, and if so, throw error
for mandatory_arg in ${mandatory_args[@]}; do
    if [[ ! " ${script_arg_keys[@]} " =~ " $mandatory_arg " ]]; then
        echo "error: variable $mandatory_arg was not provided or was empty. exiting."
        exit 2;
    fi
done

# Optional params: check if key was not provided, and if so, default to something
for optional_arg in ${optional_args[@]}; do
    optional_arg_key=$(echo $optional_arg | cut -d '=' -f 1)
    optional_arg_value=$(echo $optional_arg | cut -d '=' -f 2-)
    
    if [[ ! " ${script_arg_keys[@]} " =~ " $optional_arg_key " ]]; then
        echo "warning: variable $optional_arg_key was not provided or was empty...will default to $optional_arg_value"
        SAGCCANT_TEMPLATE_PARAMS="$SAGCCANT_TEMPLATE_PARAMS -D$optional_arg_key=$optional_arg_value"
    fi
done

if [ $DEBUG == true ]; then
    echo "All Params: ${SAGCCANT_TEMPLATE_PARAMS}"
fi

##### apply template
$SAGCCANT_CMD -Denv.CC_CLIENT=$CC_CLIENT \
              -Dbuild.dir=$ANT_BUILD_DIR \
              -Dinstall.dir=$INSTALL_DIR \
              -Dbootstrap.install.dir=$INSTALL_DIR \
              -Dbootstrap.install.installer.version=$CC_BOOTSTRAPPER_VERSION \
              -Dbootstrap.install.installer.version.fix=$CC_BOOTSTRAPPER_VERSION_FIX \
              ${SAGCCANT_TEMPLATE_PARAMS} \
              setup

runexec=$?

if [ "x$STATUS_ID" != "x" ]; then
    STATUS_ID="_$STATUS_ID"
fi

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