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

Let’s Open your GitHub and select your Repository.

In my case it is Netflix-clone and Click on Settings

Settings -> Secrets & Variables -> Actions -> New repository secrets



