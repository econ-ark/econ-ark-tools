# Docker setup for Econ-Ark

To make sure we have stable and reproducible environments we use docker containers to run our code and use jupyter notebooks running inside the docker container.
The Docker image contains all the essential tools to execute and develop code with Econ-Ark.

The following setup requires you to sign up for a DockerHub account as that is required to download the desktop application (MacOS and Windows). If you are using Ubuntu or any other Linux distribution you can install docker engine through the terminal.

##### Install Docker Desktop (MacOS and Windows)
1. Follow the instructions at https://www.docker.com/products/docker-desktop

##### Install Docker Engine on Linux distributions
1. For a quick setup on Ubuntu/debian based machines run the following commands in your terminal to install the docker CLI.
```
$ sudo apt update 
$ sudo apt install apt-transport-https ca-certificates curl software-properties-common 
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
$ sudo apt update
$ sudo apt install docker-ce
```
2. To check that docker is running in the background, run the following command in the terminal
```
$ sudo systemctl status docker
```
3. For detailed installation instructions go through https://docs.docker.com/install/

##### Start the notebook environment (MacOS and Linux).
1. Once you have docker running in the background go to the terminal and execute the following command.
```
docker run -v "$PWD":/home/jovyan/work -p 8888:8888 econark/econ-ark-notebook
```
NOTE: This command can take some time the first time you run this as it will download the docker image (1.8GB), further runs will use the local cached copy.
NOTE: Depending on your current directory this command will start a notebook server in that directory (usually your home directory by default) and to make sure you save your notebook on your local machine save it in the `work/` directory as anything outside that will be cleaned as soon as you close the notebook server.
This will start a notebook server inside the docker container and it will open a web browser with the jupyter notebooks.
If the browser isn't opened automatically you can copy the  URL (use the http://127.0.0.1:8888 address) from the output of this command and paste it in your browser.

```
To access the notebook, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/nbserver-6-open.html
    Or copy and paste one of these URLs:
        http://18f26c56f559:8888/?token=52883fc3782b6aff65e27be8e7326d0dae86a14b5ffedc95
     or http://127.0.0.1:8888/?token=52883fc3782b6aff65e27be8e7326d0dae86a14b5ffedc95
```
2. Once you are done with the work you can close the notebook server by going back to the terminal and pressing CTRL+C.

## Run your scripts and tests without starting up the docker container or jupyter lab/notebooks.

To test out if we can run scripts inside the docker environment let's use this script.
```
$ docker run -v "$PWD":/home/jovyan/work -it --rm econark/econ-ark-notebook start.sh ipython work/hark_test.py
```
NOTE: `hark_test.py` should be in the same directory you run this command from, i.e. `ls` just before this directory should show `hark_test.py`.


