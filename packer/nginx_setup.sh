#!/bin/bash

# Packer needs to wait until the server is ready. 30 seconds seems safe.
sleep 30

# Update the packages on the server
sudo yum update -y

# Install & setup nginx
sudo amazon-linux-extras install nginx1 -y
sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf
sudo systemctl enable nginx
sudo systemctl start nginx