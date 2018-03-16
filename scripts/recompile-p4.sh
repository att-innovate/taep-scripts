#!/bin/bash

BF_SDE_VERSION=7.0.0.18
ROOT_DIRECTORY=/root
BF_SDE_DIRECTORY=/root/bf-sde
P4_INSTALL_DIRECTORY=/root/bf-sde/install/lib/tofinopd/l2_switching

SCRIPTS_DIRECTORY=$ROOT_DIRECTORY/taep-scripts

# Set standard P4 build paths
SDE=$BF_SDE_DIRECTORY
SDE_INSTALL=$SDE/install
PATH=$SDE_INSTALL/bin:$PATH

# Build TAEP P4 code
cd $BF_SDE_DIRECTORY
cd pkgsrc/p4-build
./configure --prefix=$SDE_INSTALL --enable-thrift --with-tofino P4_NAME=l2_switching P4_PATH=${SCRIPTS_DIRECTORY}/p4/l2_switching/l2_switching.p4
make
make install

cd $SCRIPTS_DIRECTORY
