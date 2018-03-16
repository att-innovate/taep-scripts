#!/bin/bash

BF_SDE_VERSION=7.0.0.18
ROOT_DIRECTORY=/root
BF_SDE_DIRECTORY=/root/bf-sde
P4_INSTALL_DIRECTORY=/root/bf-sde/install/lib/tofinopd/l2_switching

SCRIPTS_DIRECTORY=$ROOT_DIRECTORY/taep-scripts
ANALYTICS_DIRECTORY=$ROOT_DIRECTORY/taep-analytics
CONTROLLER_DIRECTORY=$ROOT_DIRECTORY/taep-controller

# Set standard P4 build paths
SDE=$BF_SDE_DIRECTORY
SDE_INSTALL=$SDE/install
PATH=$SDE_INSTALL/bin:$PATH

# Check for required bf software
if [ ! -d $BF_SDE_DIRECTORY ]
then
  echo "Can't find /root/bf-sde"
  exit 1
fi

if [ ! -d /root/bf-sde-${BF_SDE_VERSION} ]
then
  echo "Can't find /root/bf-sde-${BF_SDE_VERSION}"
  exit 1
fi

# Get Taep-Analytics
if [ ! -d $ANALYTICS_DIRECTORY ]
then
  cd $ROOT_DIRECTORY
  git clone https://github.com/att-innovate/taep-analytics.git
fi

# Get Taep-Controller
if [ ! -d $CONTROLLER_DIRECTORY ]
then
  cd $ROOT_DIRECTORY
  git clone https://github.com/att-innovate/taep-controller.git
fi

# Build TAEP P4 code
if [ ! -d $P4_INSTALL_DIRECTORY ]
then
  cd $BF_SDE_DIRECTORY
  cd pkgsrc/p4-build/
  ./configure --prefix=$SDE_INSTALL --enable-thrift --with-tofino P4_NAME=l2_switching P4_PATH=${CONTROLLER_DIRECTORY}/p4/l2_switching/l2_switching.p4
  make P4FLAGS='--placement pragma'
  make install
fi

# Install Tools
apt-get -y install curl

# Install Docker and Docker-Compose
if [ ! -f /usr/bin/docker ]
then
  apt-get -y install \
     apt-transport-https \
     ca-certificates \
     gnupg2 \
     software-properties-common
  
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable"
  
  apt-get update
  apt-get -y install docker-ce

  curl -L "https://github.com/docker/compose/releases/download/1.11.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# Install Rust
if [ ! -f /root/.cargo/bin/rustc ]
then
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  source ~/.profile
fi

# Build Taep-Analytics
cd $ANALYTICS_DIRECTORY
./scripts/build-it.sh

# Build Taep-Controller
apt-get -y install libclang-dev
cd $CONTROLLER_DIRECTORY
cargo build

# Install TAEP Service script and required huge page settings
if [ ! -f /etc/init.d/taep ]
then
  $BF_SDE_DIRECTORY/install/bin/dma_setup.sh
  cp $SCRIPTS_DIRECTORY/services/taep /etc/init.d/
  update-rc.d taep defaults
fi

# Add useful Paths to .profile
if ! grep -q "SDE" /root/.profile
then
  tee -a /root/.profile << END

# Set path to Barefoot libraries
export LD_LIBRARY_PATH=/root/bf-sde/install/lib/tofinopd/l2_switching:/root/bf-sde/install/lib

# Set BF environment
export SDE=/root/bf-sde
export SDE_INSTALL=$SDE/install
export PATH=$SDE_INSTALL/bin:$PATH
END
  echo 
  echo "!! To set env variables for current session run: source /root/.profile"
fi

cd $SCRIPTS_DIRECTORY

