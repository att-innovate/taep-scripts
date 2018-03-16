## TAEP-Scripts
This project contains the scripts to build and manage all the TAEP components.

For any additional information regarding TAEP please refer to [github.com/att-innovate/taep](https://github.com/att-innovate/taep).

### Installation

#### Prerequisites

Software:
- ONL-2.0.0 2017-08-02.0609 installed
- bf-sde-7.0.0.18 installed and built
- git installed, `$ apt-get install git`

The scripts and code relying on the Barefoot-SDE assume that bf-sde is installed on the switch as follow, with a symlink from `bf-sde` to `/root/bf-sde-7.0.0.18`.

	/root
		bf-sde -> /root/bf-sde-7.0.0.18
		bf-sde-7.0.0.18/ 

#### Install TAEP Software

There is one script that deploys all the TAEP software and all its dependencies.

All the scripts must be run from the `/root/taep-scripts` directory on the switch.

	$ cd /root
	$ git clone https://github.com/att-innovate/taep-scripts
	$ cd /taep-scripts
	$ ./scripts/deploy-taep.sh

This will take a while. At the end you should see:

	!! To set env variables for current session run: source /root/.profile"

#### Configure Analytics Stack

To do an initial configuration of the Analytics Stack run:

	$ ./scripts/configure-analytics.sh

A successful run is indicated by following output:

	Stopping docker_agent_1 ... done
	Stopping docker_influxdb_1 ... done
	Stopping docker_kapacitor_1 ... done
	Stopping docker_grafana_1 ... done
	Stopping docker_telegraf_1 ... done

Btw, the output will contain the log output of the individual components. It is normal to see errors like `Database creation failed:`. The database takes some time to start up, during that time the different components relying on `influxdb` try to connect to the database. They automatically retry until they can finish their initalization step.

### Verify Installation

After the installation is done the directory structure on the switch should look as follow:

	/root
		bf-sde -> /root/bf-sde-7.0.0.18
		bf-sde-7.0.0.18/ 
		taep-analytics/
		taep-controller/
		taep-data/
		taep-scripts/

There should be a compiled binary for the TAEP-Controller:

	$ ls /root/taep-controller/target/debug/taep_controller

A service definition for the TAEP-Controller:

	$ ls /etc/init.d/taep 

Plus the TAEP P4 code (l2_switching) should be part of the bf-sde build:

	$ ls /root/bf-sde/install/lib/tofinopd/l2_switching/ 

### Running TAEP

Everything is now ready to be used for network analysis and/or experiments. For examples, please refer to [TAEP-Examples](https://github.com/att-innovate/taep/blob/master/EXAMPLES.md).

### Recompile Core Components

If you change any controller code scripts are available to recompile the TAEP-Controller code and the TAEP specific P4 code.

The TAEP controller is using interfaces that get dynamically generated based on the P4 code. Recompile the controller after every change in the P4 code.

Recompile P4:

	$ cd /root/taep-scripts/
	$ ./scripts/recompile-p4.sh

Recompile the TAEP-Controller, and force it to rebuild the stubs:

	$ touch /root/taep-controller/build.rs 
	$ cd /root/taep-scripts/
	$ ./scripts/recompile-controller.sh

### Available Scripts

This project contains following scripts:

- `./scripts/configure-analytics.sh` : Initial configuration of the Analytics Stack
- `./scripts/deploy-taep.sh` : Initial installation of all the software components and its dependencies
- `./scripts/log-controller.sh` : View the log from the TAEP-Controller, `ctrl-c` to stop
- `./scripts/recompile-controller.sh` : Recompile TAEP-Controller
- `./scripts/recompile-p4.sh` : Recompile P4 code
- `./scripts/run-analytics.sh` : Start all analytics components.
- `./scripts/stop-analytics.sh` : Stop all analytics components.