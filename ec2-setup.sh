#!/bin/bash

# EC2 Setup Script for Blog App
# This script installs all required dependencies on your EC2 instance
# Run as: bash ec2-setup.sh

set -e

echo "========================================"
echo "Starting EC2 Setup for Blog App"
echo "========================================"

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install Node.js (v18)
echo "Installing Node.js v18..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify Node.js installation
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# Install PM2 globally
echo "Installing PM2 globally..."
sudo npm install -g pm2
sudo pm2 startup
sudo pm2 save

# Install Git
echo "Installing Git..."
sudo yum install -y git

# Install Docker
echo "Installing Docker..."
sudo yum install -y docker

# Start Docker service
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group (to run without sudo)
echo "Adding ec2-user to docker group..."
sudo usermod -a -G docker ec2-user

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo chown root:root /usr/local/bin/docker-compose

# Verify Docker Compose installation
echo "Docker Compose version: $(docker-compose --version)"

# Install PostgreSQL client (optional, for database management)
echo "Installing PostgreSQL client..."
sudo yum install -y postgresql15

# Create application directory
echo "Creating application directory..."
mkdir -p /home/ec2-user/blog-app
sudo chown -R ec2-user:ec2-user /home/ec2-user/blog-app

# Set up firewall rules (if using)
echo "Configuring firewall..."
sudo firewall-cmd --permanent --add-port=5000/tcp || true
sudo firewall-cmd --permanent --add-port=3000/tcp || true
sudo firewall-cmd --permanent --add-port=5432/tcp || true
sudo firewall-cmd --permanent --add-port=80/tcp || true
sudo firewall-cmd --permanent --add-port=443/tcp || true
sudo firewall-cmd --reload || true

echo "========================================"
echo "EC2 Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Clone your repository:"
echo "   cd /home/ec2-user"
echo "   git clone https://github.com/Avivarma1/AVI_27_2_BLOG-APP.git blog-app"
echo ""
echo "2. Create .env file in blog-app directory with your secrets:"
echo "   DB_USER=postgres"
echo "   DB_PASSWORD=your-secure-password"
echo "   DB_NAME=content_db"
echo "   JWT_SECRET=your-jwt-secret"
echo ""
echo "3. Start the application:"
echo "   cd /home/ec2-user/blog-app"
echo "   docker-compose up -d"
echo ""
echo "4. Verify all containers are running:"
echo "   docker ps"
echo ""
