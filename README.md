# HandsOnLab-automation-build-angular-app-with-jenkins
Automation build Angular application with Jenkins

## Prerequisites
Minimum hardware requirements:
- 256 MB of RAM
- 1 GB of drive space (although 10 GB is a recommended minimum if running Jenkins as a Docker container)

Software requirements:
- Docker

## Downloading and running Jenkins in Docker
On macOS and Linux
```bash
# Create a bridge network in Docker using the following docker network create command:

docker network create jenkins

# Create the following volumes to share the Docker client TLS certificates needed to connect to the Docker daemon and persist the Jenkins data using the following docker volume create commands:

docker volume create jenkins-docker-certs
docker volume create jenkins-data

# In order to execute Docker commands inside Jenkins nodes, download and run the docker:dind Docker image using the following docker container run command:

docker container run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind
```
1. `--name jenkins-docker` ---- ( Optional ) Specifies the Docker container name to use for running the image. By default, Docker will generate a unique name for the container.
1. `--rm` ---- ( Optional ) Automatically removes the Docker container (the instance of the Docker image) when it is shut down. This contains the Docker image cache used by Docker when invoked from the `jenkinsci/blueocean` container described below.
1. `--detach` ---- ( Optional ) Runs the Docker container in the background. This instance can be stopped later by running `docker container stop jenkins-docker` and started again with docker `container start jenkins-docker`. See docker container for more container management commands.
1. `--privileged` ---- Running Docker in Docker currently requires privileged access to function properly. This requirement may be relaxed with newer Linux kernel versions.
1. `--network jenkins` ---- This corresponds with the network created in the earlier step.
1. `--network-alias docker` ---- Makes the Docker in Docker container available as the hostname `docker` within the `jenkins` network.
1. `--env DOCKER_TLS_CERTDIR=/certs` ---- Enables the use of TLS in the Docker server. Due to the use of a privileged container, this is recommended, though it requires the use of the shared volume described below. This environment variable controls the root directory where Docker TLS certificates are managed.
1. `--volume jenkins-docker-certs:/certs/client` ---- Maps the `/certs/client` directory inside the container to a Docker volume named `jenkins-docker-certs` as created above.
1. `--volume jenkins-data:/var/jenkins_home` ---- Maps the `/var/jenkins_home directory` inside the container to the Docker volume named `jenkins-data` as created above. This will allow for other Docker containers controlled by this Docker container’s Docker daemon to mount data from Jenkins.
1. `--publish 2376:2376` ---- ( Optional ) Exposes the Docker daemon port on the host machine. This is useful for executing `docker` commands on the host machine to control this inner Docker daemon.
1. `docker:dind` ---- The `docker:dind` image itself. This image can be downloaded before running by using the command: `docker image pull docker:dind`.

## References
https://www.jenkins.io/doc/book/installing/docker/

https://www.jenkins.io/doc/tutorials/build-a-node-js-and-react-app-with-npm/