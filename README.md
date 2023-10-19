
# CircleCI Documentation


Status Badges:  

[![CircleCI](https://dl.circleci.com/status-badge/img/circleci/K8vHSQovhLv8kMBfzEcXGd/H5KJv41WutZFoxziJ3do2/tree/main.svg?style=svg&circle-token=da6205b1662e43ca3b70d4d357865055b767a341)](https://dl.circleci.com/status-badge/redirect/circleci/K8vHSQovhLv8kMBfzEcXGd/H5KJv41WutZFoxziJ3do2/tree/main)

Visits:

![Visitor Count](https://profile-counter.glitch.me/gauravbarakoti/count.svg)



https://circleci.com/docs/configuration-reference/

This documentation will help you understand CircleCI and help deploy your application with approximately no downtime on a server using the CircleCI pipeline.

We'll start from the very basics.

Take any server in our case I'm proceeding with an Ubuntu server on AWS.

I have a sample `FLASK` application.

Now, we require `Apache` and `Docker`.

# Apache and Docker Installation Documentation

This documentation provides step-by-step instructions for installing Apache web server and Docker on your server. Additionally, it includes guidance on hosting a Python Flask application inside a Docker container, where Apache will act as a load balancer to ensure zero downtime during code updates triggered through the CircleCI pipeline.

## Table of Contents
- [Apache Installation](#apache-installation)
- [Docker Installation](#docker-installation)
- [Hosting Python Flask Application in Docker with Apache Load Balancer](#hosting-python-flask-application-in-docker-with-apache-load-balancer)
- [CircleCI pipeline to Automate Deployment of New versions](#circleci-pipeline-to-automate-deployment-of-new-versions)

---

## Apache Installation 

Apache is a widely-used web server software. Follow these steps to install Apache:

You can refer to this document or copy these commands:

https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-20-04

```bash
# Update package lists
sudo apt-get update
```
```bash
# Install Apache
sudo apt-get install apache2
```
```bash
# Start Apache
sudo systemctl start apache2
```
```bash
# Check Apache Status
sudo systemctl status apache2
```

To test if Apache is running, open a web browser and enter your server's IP address. You should see the default Apache page.

---

## Docker Installation 

Docker is a platform for developing, shipping, and running applications. Docker containers offer the perfect host for small independent applications. 

Document for docker installation:
https://docs.docker.com/engine/install/ubuntu/

To install Docker, follow these steps:

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

To install the latest version, run:
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Test Docker installation by running:

```bash
sudo docker --version
```

---

## Hosting Python Flask Application in Docker with Apache Load Balancer 

Now, let's host your Python Flask application inside a Docker container and configure Apache as a load balancer.

1. **Build Docker Image**: Create a Dockerfile for your Flask app and build the Docker image.


   Build the image:

   ```bash
   sudo docker build -t flask-app .
   ```

2. **Run Docker Container**: Run the Docker container and map the necessary ports:

    e.g.

   ```bash
   docker run -d -p 8081:5000 flask-app
   ```

   This will start your Flask app inside a Docker container, exposed on port 8080.

3. **Configure Apache Load Balancer**: Install and configure Apache as a reverse proxy and load balancer. Create an Apache configuration file for your Flask app (e.g., `myapp.conf`) in `/etc/apache2/sites-available/`:

    Install Required Apache modules:
    
    ```bash
    sudo a2enmod proxy
    ```
    mod_proxy is the main proxy module that redirects requests and allows Apache to act as gateway to backend servers.
    ```bash
    sudo a2enmod proxy_http
    ```
    mod_proxy_http allows support for proxying HTTP requests.
    ```bash
    sudo a2enmod proxy_balancer
    ```
    ```bash
    sudo a2enmod lbmethod_byrequests
    ```
    mod_proxy_balancer and mod_lbmethod_byrequests add load balancing capabilities to Apache web server.

    changes in apache 000-default.conf
    ```bash
    cd /etc/apache2/sites-available/ 
    ```
    ```bash
    sudo vi 000-default.conf
    ```

   ```apache
   <VirtualHost *:80>
        #...
        <Proxy "balancer://mycluster">
                BalancerMember "http://localhost:8081"
                BalancerMember "http://localhost:8082"
        </Proxy>
        ProxyPreserveHost On
        # ProxyPreserveHost causes Apache to preserve original host header and pass it to back-end servers.
        ProxyPass "/" "balancer://mycluster/"
        ProxyPassReverse "/" "balancer://mycluster/"
        # We list our backend servers in Proxy tag named balancer://mycluster . You can change it to anything else.
        #...
   </VirtualHost>
   ```

   Enable the new configuration and reload Apache:

   ```bash
   sudo systemctl reload apache2
   ```

Now, your Flask application should be accessible via Apache on port 80. Apache will act as a load balancer, providing zero downtime when you push new code versions through your CircleCI pipeline.

## CircleCI pipeline to Automate Deployment of New versions

Build, test, and deploy by using intelligent automation.

![App Screenshot](https://circleci.com/docs/assets/img/docs/arch.png)


You can follow the official documentation

https://circleci.com/docs/first-steps/

Or follow these steps ->

- Go to: https://circleci.com/signup/  -> Sign Up  -> Provide Email and Password

On the Welcome page provide the necessary details.

- Now, Connect to your code using GitHub, GitLab.com, Bitbucket.

For now, I'm proceeding with GitHub.

- Firstly you will not have any projects that CircleCI follows.

- Go to Projects and Follow the repository that you want CircleCI to follow.

- Click on Self-Hosted Runners -> Create Resource Class

*CircleCI’s self-hosted runner enables you to use your own infrastructure for running jobs.*

- Enter namespace or go with the default provided and a Resource Class `any custom name`.

A namespace can only be created once for your organization.

- Copy and Save the resource class token it is needed later on, and Select Machine.

- Now proceed with the commands on that page 

```bash
neofetch
# For your linux machine information
```

- Create the circleci user & working directory
These will be used when executing the task agent. These commands must be run as a user with permissions to create other users (e.g. root)

```bash
id -u circleci &>/dev/null || sudo adduser --disabled-password --gecos GECOS circleci

sudo mkdir -p /var/opt/circleci
sudo chmod 0750 /var/opt/circleci
sudo chown -R circleci /var/opt/circleci /opt/circleci/circleci-launch-agent
```

- Create a CircleCI runner configuration
Create a config file, `/etc/opt/circleci/launch-agent-config.yaml`. It must be owned by circleci with permissions 600

```bash
sudo mkdir -p /etc/opt/circleci
sudo touch /etc/opt/circleci/launch-agent-config.yaml
sudo chown circleci: /etc/opt/circleci/launch-agent-config.yaml
sudo chmod 600 /etc/opt/circleci/launch-agent-config.yaml
```
Replace AUTH_TOKEN with your resource class token. Replace RUNNER_NAME with the name you would like for your self-hosted runner. RUNNER_NAME is unique to the machine that is installing the runner. When complete, save the template as launch-agent-config.yaml.

It should look like this:
```bash
api:
  auth_token: <provide your token> 9a05a48b5207a1eaf5 <something like this>

runner:
  name: RUNNER_NAME
  working_directory: /var/opt/circleci/workdir
  cleanup_working_directory: true
```

- Enable the systemd unit

```bash
sudo touch /usr/lib/systemd/system/circleci.service
sudo chown root: /usr/lib/systemd/system/circleci.service
sudo chmod 644 /usr/lib/systemd/system/circleci.service
```

- **You must ensure that TimeoutStopSec (in `/usr/lib/systemd/system/circleci.service` file) is greater than the total amount of time a task will run for - which defaults to 5 hours.

- You can now enable the service:
```bash
sudo systemctl enable circleci.service
```

- Start the service
```bash
sudo systemctl start circleci.service
```

You have successfully configured your machine with CircleCI.

Now you can deploy your code on this machine using the CircleCI pipeline.

In CircleCI we have to create a `.circleci/config.yml` file which contains our pipeline steps and workflow.

pipeline will not work if the name is `config.yaml`, so the name of the file must be `config.yml`

Demo pipeline to explain config.yml file

Please refer the `config.yml` in the `.circleci folder` here is just a `glimpse of the explanation` of it.

```bash
version: 2.1
# The version field is intended to be used in order to issue warnings for deprecation or breaking changes.
jobs:
# A Workflow is comprised of one or more uniquely named jobs.
  runner-deploy:
  # Name for a job, can be anything
    machine: true
    # The virtual machine image to use. 
    resource_class: k8vhsqovhlv8kmbfzecxgd/docker
    # The resource_class feature allows you to configure CPU and RAM resources for each job.
    working_directory: ~/my-app
    # Not Required, In which directory to run the steps. Will be interpreted as an absolute path. (default: .)
    steps:
    # A list of steps to be performed.
      - checkout
      # the checkout step will checkout project source code into the job’s working_directory
      - run:
      # Used for invoking all command-line programs
          name: Remove previous Image If Any keep last 2 version
          # Command to run via the shell
          command: |
            .
            .
            .
            .

workflows:
# Used for orchestrating all jobs.
  version: 2
  # The Workflows version field is used to issue warnings for deprecation or breaking changes. Required if config version is 2
  build-deploy:
    jobs:
    # A job name that exists in your config.yml
      - runner-deploy

```

Our pipeline workflow:
- 
- As you push your code to the GitHub repository that is configured with CircleCI.
- CircleCI build will triggered and our pipeline will run.
- First, it builds the docker image.
- Second, it runs a container from that image.
- sleep for 15s.
- Then, runs another container.

For the new version of code deployment
-
- First, it will build the docker image.
- Also, It will stop a container and Remove it.
- Launch a new container using this image and wait for 15s.
- Then, stop another container and Remove it.
- Launch 2nd container.



NOTE:
-
- If any command fails to execute in the pipeline, please check for sudo permissions for the circleci user that we have previously created.
```bash
sudo su
su circleci
sudo vim /etc/sudoers
```
- Add 
```bash
circleci ALL=(ALL:ALL) NOPASSWD:ALL
```
In this way, we can achieve no downtime when deploying any new version of our application.

Feel free to adapt this documentation to your specific requirements and Flask application configuration.






# **Thank You**

I hope you find it useful. If you have any doubt in any of the step then feel free to contact me.
If you find any issue in it then let me know.

<!-- [![Build Status](https://img.icons8.com/color/452/linkedin.png)](https://www.linkedin.com/in/gaurav-barakoti-27002223b) -->


<table>
  <tr>
    <th><a href="https://www.linkedin.com/in/gaurav-barakoti-27002223b" target="_blank"><img src="https://img.icons8.com/color/452/linkedin.png" alt="linkedin" width="30"/><a/></th>
    <th><a href="mailto:bestgaurav1234@gmail.com" target="_blank"><img src="https://img.icons8.com/color/344/gmail-new.png" alt="Mail" width="30"/><a/>
</th>
  </tr>
</table>
