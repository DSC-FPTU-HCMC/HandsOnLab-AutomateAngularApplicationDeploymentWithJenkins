# HandsOnLab-automation-build-angular-app-with-jenkins
Automation build Angular application with Jenkins

## Prerequisites
Minimum hardware requirements:
- 256 MB of RAM
- 1 GB of drive space (although 10 GB is a recommended minimum if running Jenkins as a Docker container)

Software requirements:
- Docker

Knowledge requirements:
- Node
- Angular
- NPM (node package manager)
- Jenkins
- Docker

## Downloading and running Jenkins in Docker with your local machine
**On macOS and Linux**
```bash
# Create a bridge network in Docker using the following docker network create command:

docker network create jenkins

# Create the following volumes to share the Docker client TLS certificates needed to connect to the Docker daemon and persist the Jenkins data using the following docker volume create commands:

docker volume create jenkins-docker-certs
docker volume create jenkins-data

# In order to execute Docker commands inside Jenkins nodes, download and run the `docker:dind` Docker image using the following docker container run command:

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

```bash
# Download the `jenkinsci/blueocean` image and run it as a container in Docker using the following docker container run command:

docker container run \
  --name jenkins-blueocean \
  --rm \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  jenkinsci/blueocean
```
1. `--name jenkins-blueocean` ---- ( Optional ) Specifies the Docker container name for this instance of the `jenkinsci/blueocean` Docker image. This makes it simpler to reference by subsequent docker container commands.
1. `--rm` ---- ( Optional ) Automatically removes the Docker container (which is the instantiation of the `jenkinsci/blueocean` image below) when it is shut down. This keeps things tidy if you need to quit Jenkins.
1. `--detach` ---- ( Optional ) Runs the `jenkinsci/blueocean` container in the background (i.e. "detached" mode) and outputs the container ID. If you do not specify this option, then the running Docker log for this container is output in the terminal window.
1. `--network jenkins` ---- Connects this container to the `jenkins` network defined in the earlier step. This makes the Docker daemon from the previous step available to this Jenkins container through the hostname `docker`.
1. `--env DOCKER_HOST=tcp://docker:2376`, `--env DOCKER_CERT_PATH=/certs/client`, `--env DOCKER_TLS_VERIFY=1` ---- Specifies the environment variables used by docker, docker-compose, and other Docker tools to connect to the Docker daemon from the previous step.
1. `--publish 8080:8080` ---- Maps (i.e. "publishes") port `8080` of the `jenkinsci/blueocean` container to port `8080` on the `host machine`. The first number represents the port on the host while the last represents the container’s port. Therefore, if you specified `-p 49000:8080` for this option, you would be accessing Jenkins on your host machine through port `49000`.
1. `--publish 50000:50000` ---- ( Optional ) Maps port `50000` of the `jenkinsci/blueocean` container to port `50000` on the host machine. This is only necessary if you have set up one or more inbound Jenkins agents on other machines, which in turn interact with the `jenkinsci/blueocean` container (the Jenkins "controller"). Inbound Jenkins agents communicate with the Jenkins controller through TCP port `50000` by default. You can change this port number on your Jenkins controller through the Configure Global Security page. If you were to change the TCP port for inbound Jenkins agents of your Jenkins controller to `51000` (for example), then you would need to re-run Jenkins (via this `docker run …​ `command) and specify this "publish" option with something like `--publish 52000:51000`, where the last value matches this changed value on the Jenkins controller and the first value is the port number on the machine hosting the Jenkins controller. Inbound Jenkins agents communicate with the Jenkins controller on that port (52000 in this example). Note that WebSocket agents in Jenkins 2.217 do not need this configuration.
1. `--volume jenkins-data:/var/jenkins_home` ---- Maps the `/var/jenkins_home` directory in the container to the Docker volume with the name `jenkins-data`. Instead of mapping the `/var/jenkins_home` directory to a Docker volume, you could also map this directory to one on your machine’s local file system. For example, specifying the option `--volume $HOME/jenkins:/var/jenkins_home` would map the container’s `/var/jenkins_home` directory to the jenkins subdirectory within the `$HOME` directory on your local machine, which would typically be `/Users/<your-username>/jenkins` or `/home/<your-username>/jenkins`. Note that if you change the source volume or directory for this, the volume from the docker:dind container above needs to be updated to match this.
1. `--volume jenkins-docker-certs:/certs/client:ro` ---- Maps the `/certs/client` directory to the previously created `jenkins-docker-certs` volume. This makes the client TLS certificates needed to connect to the Docker daemon available in the path specified by the `DOCKER_CERT_PATH` environment variable.
1. `jenkinsci/blueocean` ---- The `jenkinsci/blueocean` Docker image itself. If this image has not already been downloaded, then this docker container run command will automatically download the image for you. Furthermore, if any updates to this image were published since you last ran this command, then running this command again will automatically download these published image updates for you.

**Note**: This Docker image could also be downloaded (or updated) independently using the docker image pull command:
`docker image pull jenkinsci/blueocean`

```bash
# Connect to `jenkins-blueocean` container

docker exec -it jenkins-blueocean bash
```

## Unlocking Jenkins
When you first access a new Jenkins instance, you are asked to unlock it using an automatically-generated password.

1. After the 2 sets of asterisks appear in the terminal/command prompt window, browse to http://localhost:8080 and wait until the Unlock Jenkins page appears.
1. Display the Jenkins console log with the command:
```bash
docker logs jenkins-tutorial
```
1. From your terminal/command prompt window again, copy the automatically-generated alphanumeric password (between the 2 sets of asterisks).
1. On the Unlock Jenkins page, paste this password into the Administrator password field and click Continue.

## Customizing Jenkins with plugins
After unlocking Jenkins, the `Customize Jenkins` page appears.

On this page, click `Install suggested plugins`.

The setup wizard shows the progression of Jenkins being configured and the suggested plugins being installed. This process may take a few minutes.

## Creating the first administrator user
Finally, Jenkins asks you to create your first administrator user.

1. When the `Create First Admin User` page appears, specify your details in the respective fields and click `Save and Finish`.
1. When the Jenkins is ready page appears, click `Start using Jenkins`.
Notes:
  - This page may indicate Jenkins is almost ready! instead and if so, click `Restart`.
  - If the page doesn’t automatically refresh after a minute, use your web browser to refresh the page manually.
1. If required, log in to Jenkins with the credentials of the user you just created and you’re ready to start using Jenkins!

## Stopping and restarting Jenkins
Throughout the remainder of this tutorial, you can stop your Docker container by running
`docker stop jenkins jenkins-docker`

To restart your Docker container:

1. Run the same `docker run …`​ command you ran for macOS, Linux or Windows above.
  **Note:** This process also updates your Docker image, if an updated one is available.
1. Browse to `http://localhost:8080`.
1. Wait until the log in page appears and log in.

## Fork and clone Angular project on Github
[Angular project][angular-boilerplate]

## Create your Pipeline project in Jenkins
1. Go back to Jenkins, log in again if necessary and click `create new jobs` under Welcome to Jenkins!
  Note: If you don’t see this, click `New Item` at the top left.
1. In the` Enter an item name` field, specify the name for your new Pipeline project (e.g. `simple-node-js-angular-npm-app`).
1. Scroll down and click `Pipeline`, then click `OK` at the end of the page.
1. ( Optional ) On the next page, specify a brief description for your Pipeline in the Description field (e.g. An entry-level Pipeline demonstrating how to use Jenkins to build a simple Node.js and angular application with npm.)
1. Click the `Pipeline` tab at the top of the page to scroll down to the Pipeline section.
1. From the `Definition` field, choose the `Pipeline script from SCM` option. This option instructs Jenkins to obtain your Pipeline from Source Control Management (SCM), which will be your Git repository.
1. From the `SCM` field, choose `Git`, and fill the Repository URL field.
1. Click `Save` to save your new Pipeline project. You’re now ready to begin creating your `Jenkinsfile`, which you’ll be checking into your Git repository.

## Create your initial Pipeline as a Jenkinsfile
This is the foundation of `Pipeline-as-Code`, which treats the continuous delivery pipeline as a part of the application to be versioned and reviewed like any other code. Read more about [Pipeline][jenkins-pipeline] and what a Jenkinsfile is in the Pipeline and [Using a Jenkinsfile](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/) sections of the User Handbook.
```Jenkinsfile
pipeline {
  agent {
    docker {
      image 'node:6-alpine'
      args '-p 3000:3000'
    }
  }
  environment {
    CI = 'true'
  }
  stages {
    stage('Build') {
      steps {
        sh 'npm install'
      }
    }
    stage('Test') {
      steps {
        sh './jenkins/scripts/test.sh'
      }
    }
    stage('Deliver') {
      steps {
        sh './jenkins/scripts/deliver.sh'
        input message: 'Finished using the web site? (Click "Proceed" to continue)'
        sh './jenkins/scripts/kill.sh'
      }
    }
  }
}
```

## References
- [Jenkins in Docker](https://www.jenkins.io/doc/book/installing/docker/)
- [Build a Node.js and React app with npm](https://www.jenkins.io/doc/tutorials/build-a-node-js-and-react-app-with-npm/)

[angular-boilerplate]: https://github.com/DSC-FPTU-HCMC/angular-boilerplate
[jenkins-pipeline]: https://www.jenkins.io/doc/book/pipeline/