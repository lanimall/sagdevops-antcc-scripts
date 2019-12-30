#!/bin/bash

SAGCCANT_CMD="sagccant"
ANT_CMD="ant"

CC_CLIENT=default
CC_BOOT=default
CC_ENV=default

INSTALL_DIR=/opt/softwareag
ANT_BUILD_DIR=${HOME}/sagcc/build

CC_BOOTSTRAPPER_VERSION=10.3
CC_BOOTSTRAPPER_VERSION_FIX=fix8
CC_BOOTSTRAPPER_PLATFORM=lnxamd64
CC_REPO_NAME_PRODUCTS=webMethods-10.3
CC_REPO_NAME_FIXES=Empower

##installer is local, that's where we get it from
#CC_INSTALLER_URL=./installers