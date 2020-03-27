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

## apply secrets
if [ -f ${HOME}/.setenv_cce_secrets.sh ]; then
    . ${HOME}/.setenv_cce_secrets.sh
fi

### get the args
for ARGS in "$@"
do
    KEY=$(echo $ARGS | cut -f1 -d=)
    VALUE=$(echo $ARGS | cut -f2 -d=)
    case "$KEY" in
            STATUS_ID)          STATUS_ID=${VALUE} ;;
            repo_products_version_major)   repo_products_version_major=${VALUE} ;;
            repo_products_version_minor)   repo_products_version_minor=${VALUE} ;;
            *)   
    esac
done

### optional params
if [ "x$STATUS_ID" != "x" ]; then
    STATUS_ID="_$STATUS_ID"
fi

##apply default command central license
echo "Trying to setup product repositories in Command Central"
$SAGCCANT_CMD   -Dbuild.dir=$ANT_BUILD_DIR \
                -Denv.CC_TEMPLATE=sag-cc-repos/template-products.yaml  \
                -Denv.CC_ENV=sag-cc-repos-products-empower \
                -Drepo.products.version.major=$repo_products_version_major \
                -Drepo.products.version.minor=$repo_products_version_minor \
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