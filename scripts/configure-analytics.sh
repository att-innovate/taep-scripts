#!/bin/bash

ROOT_DIRECTORY=/root
ANALYTICS_DIRECTORY=$ROOT_DIRECTORY/taep-analytics
SCRIPTS_DIRECTORY=$ROOT_DIRECTORY/taep-scripts

cd $ANALYTICS_DIRECTORY
./scripts/run-it.sh

sleep 15

./scripts/configure-grafana.sh
./scripts/configure-kapacitor-health.sh
./scripts/configure-kapacitor-agent.sh

./scripts/disable-kapacitor-agent.sh

./scripts/log-it.sh
./scripts/stop-it.sh

cd $SCRIPTS_DIRECTORY
