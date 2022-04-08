#!/bin/bash

# Execute script as root user: sh installminikube.sh <Non-root-user>
# Script is going to install minikube on the Rhel and CentOS Distribution only.
# user1 is the user which is going run minikube

localuser=$1

#1 Checking OS distribution
OSDist=`egrep "centos|rhel" /etc/os-release | head -1 |cut -d'"' -f2`

if [ $OSDist == "centos" ] || [ $OSDist == "rhel" ]; then
	echo "OS Distribution is $OSDist"
	#updting all packages
	sudo yum repolist enabled
	sudo yum update -y
	sudo yum install -y yum-utils
else
	echo "Please check the OS Distribution. Must have to be RHEL or CentOS"
	exit 1
fi

#2. Installing Curl utility
sudo yum list installed | grep libcurl
if [ "$?" != "0" ]; then
	echo "Curl not present... installing"
	sudo yum install -y libcurl
fi

#3. Installing and starting MiniKube cluster
echo "Installing MiniKube cluster..."

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube
if [ $? == 0 ]; then
	echo "MiniKube installed successfully."
else
	echo "Error installing minikube cluser"
	exit 1
fi

#4. Install Terraform
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform

echo "$localuser ALL=(ALL) NOPASSWD: /usr/bin/podman" >> /etc/sudoers