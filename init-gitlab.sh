#!/bin/bash

# Update the system
sudo yum update -y

# Install Docker
sudo amazon-linux-extras install docker -y

# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Add the current user to the Docker group to avoid using 'sudo' with Docker commands
sudo usermod -aG docker $USER

# Install Git (optional, in case you want to clone repos in the future)
sudo yum install git -y

# Log out and back in to apply the Docker group membership, or run the following command:
newgrp docker

# Pull the GitLab Docker image (use the latest GitLab image or specify a version)
docker pull gitlab/gitlab-ee:latest

# Create directories for GitLab's configuration, logs, and data
sudo mkdir -p /srv/gitlab/config /srv/gitlab/logs /srv/gitlab/data

# Set permissions for the directories (optional)
sudo chown 1000:1000 /srv/gitlab/config /srv/gitlab/logs /srv/gitlab/data

# Run GitLab container
docker run -d \
  --hostname gitlab.local \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab \
  --restart always \
  --volume /srv/gitlab/config:/etc/gitlab \
  --volume /srv/gitlab/logs:/var/log/gitlab \
  --volume /srv/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ee:latest
