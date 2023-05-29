#!/bin/bash
yum update -y
sudo yum install java-17-amazon-corretto -y
sudo yum install ruby -y
sudo yum install wget -y
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo yum install -y python-pip
sudo pip install awscli
sudo yum install java-17-amazon-corretto-devel.x86_64