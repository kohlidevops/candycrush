# Github Selfhosted Runner

## Launch ubuntu22 EC2 Instance

To launch ubuntu22 EC2 instance with t3.medium and staorge would be 20 GB is good.

## Create IAM Role

To Create an IAM role with below policies for EC2 instance and associate to GitHub instance to create EKS cluster with the help of terraform.

![image](https://github.com/kohlidevops/candycrush/assets/100069489/8a6e061c-8a1f-47a3-81e2-9976b3433047)

![image](https://github.com/kohlidevops/candycrush/assets/100069489/81fd42f9-d13e-4331-a1d8-6f1be26635d2)

## Add Github Action selfhosted runner to EC2 Instance

Go to GitHub -> your project (candycrush) -> click on Settings –> Actions –> Runners -> New self hosted Runner

![image](https://github.com/kohlidevops/candycrush/assets/100069489/c55d843f-42cf-43f9-a9fe-b01562481827)

![image](https://github.com/kohlidevops/candycrush/assets/100069489/601f0126-0725-4c4e-b3fd-21ad4de45ef0)

### Configure Github Runner on EC2 Instance

SSH to Github Runner EC2 instance and execute below commands (You can get those commands once you are selected new selfhosted runner)

```
sudo apt-get update -y
sudo apt-get upgrade -y
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
echo "1111111111111111122222222222222222222aaaaaaaaaaaaaaaaaaaaaaaaaa  actions-runner-linux-x64-2.311.0.tar.gz" | shasum -a 256 -c
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
./config.sh --url https://github.com/kohlidevops/candycrush --token AAAABBBBBBCCCCCDDDDEEEEE
./run.sh
```

![image](https://github.com/kohlidevops/candycrush/assets/100069489/39571a97-4c2c-49f9-9442-7d504c12e11c)

```
CNTRL+C -> To stop the runner as of now
```

### Install docker and run Sonaqube container

```
sudo apt-get update
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```

![image](https://github.com/kohlidevops/candycrush/assets/100069489/423748bd-500a-481f-a259-c4451e60ae5f)

Sonarqube application can be accessed with the help of EC2 instance IP and Port 9000.

Sonarqube default password should be changed

```
default username - admin
default password - admin
```

![image](https://github.com/kohlidevops/candycrush/assets/100069489/9d5dfd6f-cc75-4a61-b300-9f3d62d45fad)

### Integrating Sonarqube with Github Actions

To integrate the SonarQube with GitHub Actions allows you to automatically analyze your code quality and security.

Sonarqube container is up and running

On Sonarqube Dashboard click on Manually.

![image](https://github.com/kohlidevops/candycrush/assets/100069489/74774232-e728-44dc-84c2-f749da986cc4)

![image](https://github.com/kohlidevops/candycrush/assets/100069489/4eb83402-17b0-4dcd-9921-9b56b432bf98)

On the next page click on With GitHub actions

![image](https://github.com/kohlidevops/candycrush/assets/100069489/9200dc94-6918-489b-8e6b-6faf85697b10)

Now, we need to provide SONAR TOKEN & URL to Github Actions.

![image](https://github.com/kohlidevops/candycrush/assets/100069489/3b3c2d70-13aa-4d67-b24d-f1cef644cdbf)

Let’s Open your GitHub and select your Repository.

In my case it is Netflix-clone and Click on Settings

Settings -> Secrets & Variables -> Actions -> New repository secrets

![image](https://github.com/kohlidevops/candycrush/assets/100069489/cb9ab460-8b3b-47ae-83d6-9c74a0a2be30)

Now create your Workflow for your Project. In my case, the candycrush project is built using React Js. That’s why I am selecting Other.

Now it Generates and workflow for my Project.

Go back to GitHub. click on Add file and then create a new file

![image](https://github.com/kohlidevops/candycrush/assets/100069489/e9024c6e-84f5-4e5a-92ee-98f60ab2c1c1)

Now, Time to add our workflow in below path of the my repository.

```
.github/workflows/sonar.yml
```

![image](https://github.com/kohlidevops/candycrush/assets/100069489/cf1efe16-9c9c-4133-91e7-2329f81f5b31)

This workflow is triggered on a push to the main branch and contains two steps in "Build" jobs. The first step checks out the code, and the second step uses the SonarQube Scan action to analyze the code using SonarQube.

```
name: My Build
on:
  push:
    branches:
      - main
jobs:
  build:
    name: Build
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0  # Shallow clones should be disabled for a better relevancy of analysis
      - uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

Now commit the changes - Then build will start automatically. Before commit the changes, to start the run in EC2 selfhosted runner using below commands.

```
cd /home/ubuntu/actions-runner
./run.sh
```

Once its ready to listening, then it will be succeeded if build has been started.

![image](https://github.com/kohlidevops/candycrush/assets/100069489/c1e24413-d465-4034-bccf-e1527ed13fcb)

![image](https://github.com/kohlidevops/candycrush/assets/100069489/23c4d567-4800-4ffa-b63c-d2555b596c2f)

You can see the code analysis in Sonarqube instance

![image](https://github.com/kohlidevops/candycrush/assets/100069489/4de4d10d-be3b-49b8-b8bd-b52518c12422)

### Install Java

SSH to Github machine and install Java using below commands

```
sudo apt update -y
sudo touch /etc/apt/keyrings/adoptium.asc
sudo wget -O /etc/apt/keyrings/adoptium.asc https://packages.adoptium.net/artifactory/api/gpg/key/public
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update -y
sudo apt install temurin-17-jdk -y
/usr/bin/java --version
```

### Install Trivy 

SSH to Github machine and install Trivy to scan images

```
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y
trivy -v
```

### Install Terraform

SSH to Github machine to install terraform using below commands

```
sudo apt install wget -y
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
terraform -v
```

### Install Kubectl

SSH to Github machine and install kubectl

```
sudo apt update
sudo apt install curl -y
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

### Install AWSCLI

To install AWSCLI on Github macine

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install unzip -y
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

### Install NodeJS and NPM

To install nodejs and npm on Github machine using below commands

```
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_16.x focal main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install -y nodejs
node -v
npm -v
```

### To provisioning an EKS Cluster on AWS

To SSH to GIthub machine and clone the below repo and work on it.

##### To change the S3 bucket in backend.tf file

```
git clone https://github.com/kohlidevops/candycrush.git
cd /home/ubuntu/candycrush/Eks-terraform
terraform init
terraform validate
terraform plan
terraform apply --auto-approve
```

![image](https://github.com/kohlidevops/candycrush/assets/100069489/354a157b-72f9-4eba-9f84-0acdf529ce8a)

### To add NPM and Trivy taks on Github workflows

This step is responsible for installing Node.js dependencies using npm and performing a security scan using Trivy on the files in the current directory and redirecting the results to a file named "trivyfs.txt". Trivy is a vulnerability scanner for containers and file systems.

```
name: To Build, Analyze and Scan
on:
  push:
    branches:
      - main
jobs:
  build:
    name: Build
    runs-on: self-hosted
    steps:
      - name: To Checkout the Code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0  # Shallow clones should be disabled for a better relevancy of analysis
      - name: Build and Analyze with Sonarqube
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
      - name: NPM install dependency
        run: npm install
      - name: Trivy file scan
        run: trivy fs . > trivyfs.txt
```

Once update the workflow then Github action has been triggered and my job has been succeeded.

![image](https://github.com/kohlidevops/candycrush/assets/100069489/13e42084-821c-43bd-b9f9-f89158dd3970)

### To add Docker stage

First I have to create a Personal Access Token in Docker hub registry.

Go to docker hub and click on your profile –> Account settings –> security –> New access token

![image](https://github.com/kohlidevops/candycrush/assets/100069489/9b6ae3ad-12b2-4c7b-9061-83fdba935bea)

Go to my Repository -> candycrush -> Settings -> Secrets & Variables -> Actions -> New repository secret

Add DOCKERHUB_TOKEN & DOCKERHUB_USERNAME

![image](https://github.com/kohlidevops/candycrush/assets/100069489/2b380310-ef97-4da7-b8ea-b965235b8278)

### To add Docker stage to Github workflows

```
name: To Build, Analyze and Scan
on:
  push:
    branches:
      - main
jobs:
  build:
    name: Build
    runs-on: self-hosted
    steps:
      - name: To Checkout the Code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0  # Shallow clones should be disabled for a better relevancy of analysis
      - name: Build and Analyze with Sonarqube
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
      - name: NPM install dependency
        run: npm install
      - name: Trivy file scan
        run: trivy fs . > trivyfs.txt
      - name: Docker Build and push
        run: |
          docker build -t candycrush .
          docker tag candycrush latchudevops/candycrush:latest
          docker login -u ${{ secrets.DOCKERHUB_USERNAME }} -p ${{ secrets.DOCKERHUB_TOKEN }}
          docker push latchudevops/candycrush:latest
        env:
          DOCKER_CLI_ACI: 1
```

My build has been succeeded.

![image](https://github.com/kohlidevops/candycrush/assets/100069489/7fa45eb7-035e-4e3c-b083-4db18250d2ce)

Docker Image has been pushed to docker registry

![image](https://github.com/kohlidevops/candycrush/assets/100069489/14db65d6-2d5e-46e8-8b21-d899d923c04d)

### To add a trivy scan to the build job and create a deploy job

To add a trivy scan stage to build job and create one more job as deploy which is going to pull the docker image, scan the image and deploy this image on docker container in Gitub Action machine.

```
name: To Build, Analyze and Scan
on:
  push:
    branches:
      - main
jobs:
  build-analyze-scan:
    name: Build
    runs-on: self-hosted
    steps:
      - name: To Checkout the Code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0  # Shallow clones should be disabled for a better relevancy of analysis
      - name: Build and Analyze with Sonarqube
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
      - name: NPM install dependency
        run: npm install
      - name: Trivy file scan
        run: trivy fs . > trivyfs.txt
      - name: Docker Build and push
        run: |
          docker build -t candycrush .
          docker tag candycrush latchudevops/candycrush:latest
          docker login -u ${{ secrets.DOCKERHUB_USERNAME }} -p ${{ secrets.DOCKERHUB_TOKEN }}
          docker push latchudevops/candycrush:latest
        env:
          DOCKER_CLI_ACI: 1
      - name: Image scan
        run: trivy image latchudevops/candycrush:latest > trivyimage.txt
  deploy:
    needs: build-analyze-scan
    runs-on: self-hosted
    steps:
      - name: docker pull image
        run: docker pull latchudevops/candycrush:latest
      - name: Image scan
        run: trivy image latchudevops/candycrush:latest > trivyimagedeploy.txt  
      - name: Deploy to container
        run: docker run -d --name game -p 3000:3000 latchudevops/candycrush:latest
```
Once update the code then Action can be triggered.

My build job has been succeeded and deploy job too completed.

![image](https://github.com/kohlidevops/candycrush/assets/100069489/af147ab0-9a53-4caa-9126-2716b3b6fa83)

![image](https://github.com/kohlidevops/candycrush/assets/100069489/e48e5e0a-b6db-482b-9eef-d3113607ced9)

My reactapp has been deployed in container.

![image](https://github.com/kohlidevops/candycrush/assets/100069489/f0d3eb71-6bff-4ce4-b6f5-498df641ff58)

![image](https://github.com/kohlidevops/candycrush/assets/100069489/6870a53c-0211-44d4-9b82-4559ab92b286)

### Deploy to EKS Cluster

To add a EKS stage in to deploy jobs and commit the changes

```
name: To Build, Analyze and Scan
on:
  push:
    branches:
      - main
jobs:
  build-analyze-scan:
    name: Build
    runs-on: self-hosted
    steps:
      - name: To Checkout the Code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0  # Shallow clones should be disabled for a better relevancy of analysis
      - name: Build and Analyze with Sonarqube
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
      - name: NPM install dependency
        run: npm install
      - name: Trivy file scan
        run: trivy fs . > trivyfs.txt
      - name: Docker Build and push
        run: |
          docker build -t candycrush .
          docker tag candycrush latchudevops/candycrush:latest
          docker login -u ${{ secrets.DOCKERHUB_USERNAME }} -p ${{ secrets.DOCKERHUB_TOKEN }}
          docker push latchudevops/candycrush:latest
        env:
          DOCKER_CLI_ACI: 1
      - name: Image scan
        run: trivy image latchudevops/candycrush:latest > trivyimage.txt
  deploy:
    needs: build-analyze-scan
    runs-on: self-hosted
    steps:
      - name: docker pull image
        run: docker pull latchudevops/candycrush:latest
      - name: Image scan
        run: trivy image latchudevops/candycrush:latest > trivyimagedeploy.txt  
      - name: Deploy to container
        run: docker run -d --name game -p 3000:3000 latchudevops/candycrush:latest
      - name: Update kubeconfig
        run: aws eks --region ap-south-1 update-kubeconfig --name EKS_CLOUD
      - name: Deploy to kubernetes
        run: kubectl apply -f deployment-service.yml
```

Once the workflows updated then jobs automatically triggered. Finally my both build and deploy job has been succeeded.

![image](https://github.com/kohlidevops/candycrush/assets/100069489/024ac929-a951-466e-b29c-5b28cb032f5d)

If i check with Github Action machine using kubectl

```
kubectl get all
```

![image](https://github.com/kohlidevops/candycrush/assets/100069489/513ec8c0-77a4-4a27-9e3f-f622d8400545)

If I check with my loadbalancer URL, I can able to see the candycrush game.

![image](https://github.com/kohlidevops/candycrush/assets/100069489/f0ed4a0b-bd70-4646-889f-b1b653c39d83)


#### For slack integration

```
https://mrcloudbook.com/candycrush-deployment-on-aws-eks-using-github-actions-in-devsecops-pipeline/
```
