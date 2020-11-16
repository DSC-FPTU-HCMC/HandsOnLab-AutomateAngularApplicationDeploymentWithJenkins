![DSC FPTU HCMC](/assets/images/dsc-fptu-hcmc/DSC_FPT_University_HCMC_Horizontal_Logo.png)

# HandsOnLab: Automate Angular Application Deployment with Jenkins

Automation build Angular application with Jenkins

## Prerequisites
If you setup Jenkins on your local machine, you have to configure the SCM point to your local source repository on your local machine.

**Recommended**: using Google Compute Engine. It will provide you a Virtual Machine with an External IP Address which then be configured as the Webhook endpoint for repositories on SCM (Github).

Minimum hardware requirements:
- 8 GB of RAM
- 1 GB of drive space (although 10 GB is a recommended minimum if running Jenkins as a Docker container)

Software requirements:
- Docker

Knowledge requirements:
- Node
- Angular
- NPM (node package manager)
- Jenkins
- Docker

## Create Jenkins container from image `jenkinsci/blueocean`

https://hub.docker.com/r/jenkinsci/blueocean/

```bash
docker run \
  --volume jenkins-data:/var/jenkins_home \
  --publish 8080:8080 \
  --detach \
  --rm \
  jenkinsci/blueocean
```

```bash
# Connect to `jenkins` container

docker exec -it jenkinsci bash
```

## Unlocking Jenkins
When you first access a new Jenkins instance, you are asked to unlock it using an automatically-generated password.

1. After the 2 sets of asterisks appear in the terminal/command prompt window, browse to http://localhost:8080 and wait until the Unlock Jenkins page appears.
1. Display the Jenkins console log with the command:
```bash
docker logs jenkinsci
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
`docker stop jenkinsci`

To restart your Docker container:

1. Run the same `docker run …`​ command you ran for macOS, Linux or Windows above.
  **Note:** This process also updates your Docker image, if an updated one is available.
1. Browse to `http://localhost:8080`.
1. Wait until the log in page appears and log in.

## Fork and clone Angular project on Github
Fork this repository into your Github account, and clone it to your local machine.

[DSC-FPTU-HCMC/angular-boilerplate][angular-boilerplate]

We have already created the `Jenkinsfile` file. This is the foundation of `Pipeline-as-Code`, which treats the continuous delivery pipeline as a part of the application to be versioned and reviewed like any other code. Read more about [Pipeline][jenkins-pipeline] and what a Jenkinsfile is in the Pipeline and [Using a Jenkinsfile](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/) sections of the User Handbook.

## Create credential
Follow the below instruction to generate SSH authentication keys, then add to your `public key` to Github account, and `private key` to Jenkins.

[Configuring SSH authentication between GitHub and Jenkins](https://mohitgoyal.co/2017/02/27/configuring-ssh-authentication-between-github-and-jenkins/)
```bash
# Generate SSH Key on Jenkins Server
ssh-keygen -t rsa
```

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

## Build manually
- At the Jenkins Dashboard select the pipeline `simple-node-js-angular-npm-app`
- Go into the Pipeline page click Build Now

## Configure NodeJS runtime for Jenkins agent
Install NodeJS plugin
- Goto `Manage Jenkins > Manage Plugins`, then click on `Available tab
- Filter `NodeJS` and install the plugin and click `Download now and install after restart`
- The page `Installing Plugins/Upgrades` will open, then tick the checkbox `Restart Jenkins when installation is complete and no jobs are running`

After restarting, navigate to `Manage Jenkins -> Global Tool Configuration` and look for the `NodeJS`
- Install the NodeJS version that you need and click save

## Install Google OAuth Credentials and GCloud SDK plugins for Jenkins
- Goto `Manage Jenkins > Manage Plugins`, then click on `Available tab
- Filter `Google OAuth Credentials`, and click the checkbox
- Filter `GCloud SDK`, and click the checkbox
- Click `Download now and install after restart`
- The page `Installing Plugins/Upgrades` will open, then tick the checkbox `Restart Jenkins when installation is complete and no jobs are running`

After restarting, navigate to `Manage Jenkins -> Global Tool Configuration` and look for the `NodeJS`
- Install the NodeJS version that you need and click save

## Add GCP Credential to to enable Jenkins deploy our application to Google App Engine
Create service account on Google Cloud Platform:
- Goto to Google Cloud Console and navigate to [IAM & Admin > Service accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
- Create a new service account and generate a private key, then save it to your computer. This service account use for authenticate Jenkins and allow it to deploy Angular application to Google App Engine.

Add service account's private key to Jenkins:
- Goto `Manage Jenkins > Manage Credentials`
- Click `global`
- The page `Global credentials` will open, then click `Add Credentials`

## Configure Webhook with Github
[How to Integrate Your GitHub Repository to Your Jenkins Project](https://www.blazemeter.com/blog/how-to-integrate-your-github-repository-to-your-jenkins-project)

## Edit the code and push to your remote
`__do_it_yourself__`

Then open the Jenkins build status, you will see the build triggered automatically

## References
- [Jenkins in Docker](https://www.jenkins.io/doc/book/installing/docker/)
- [Build a Node.js and React app with npm](https://www.jenkins.io/doc/tutorials/build-a-node-js-and-react-app-with-npm/)
- [~jpetazzo/Using Docker-in-Docker for your CI or testing environment? Think twice.](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)
- [Docker inside Docker for Jenkins](https://itnext.io/docker-inside-docker-for-jenkins-d906b7b5f527)

[angular-boilerplate]: https://github.com/DSC-FPTU-HCMC/angular-boilerplate
[jenkins-pipeline]: https://www.jenkins.io/doc/book/pipeline/

![DSC FPTU HCMC](/assets/images/dsc-fptu-hcmc/HOME_PAGE_BANNERS.png)