#!/bin/bash

ROOT_DIRECTORY=/root
CONTROLLER_DIRECTORY=$ROOT_DIRECTORY/taep-controller
SCRIPTS_DIRECTORY=$ROOT_DIRECTORY/taep-scripts

LD_LIBRARY_PATH=/root/bf-sde/install/lib/tofinopd/l2_switching:/root/bf-sde/install/lib

cd $CONTROLLER_DIRECTORY
cargo build

cd $SCRIPTS_DIRECTORY
