#!/bin/bash

# Tomcat 11.0.15 Installation Script
# This script will install Java, download Tomcat, configure it, and start the service

echo "=========================================="
echo "Starting Tomcat 11.0.15 Installation"
echo "=========================================="

# Update system packages
echo "Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# Install Java (OpenJDK 25 - Tomcat 11 requires Java 17+)
echo "Installing OpenJDK 25..."
sudo apt install openjdk-25-jdk -y

# Install unzip utility
echo "Installing unzip..."
sudo apt install unzip -y

# Download Tomcat
echo "Downloading Tomcat 11.0.15..."
cd /opt
sudo wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.15/bin/apache-tomcat-11.0.15.zip

# Extract and rename
echo "Extracting Tomcat..."
sudo unzip apache-tomcat-11.0.15.zip
sudo mv apache-tomcat-11.0.15 tomcat

# Create tomcat user and group
echo "Creating tomcat user and group..."
sudo groupadd tomcat 2>/dev/null || echo "Group 'tomcat' already exists"
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat 2>/dev/null || echo "User 'tomcat' already exists"

# Set permissions
echo "Setting permissions..."
sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh

# Start Tomcat
echo "Starting Tomcat..."
sudo /opt/tomcat/bin/startup.sh

# Wait a few seconds for Tomcat to fully start
echo "Waiting for Tomcat to start..."
sleep 5

# Test Tomcat
echo "Testing Tomcat..."
curl -s http://localhost:8080 > /dev/null
if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "✓ Tomcat installation successful!"
    echo "✓ Tomcat is running on port 8080"
    echo "=========================================="
    echo "Access Tomcat at: http://181.41.140.18:8080"
else
    echo "=========================================="
    echo "✗ Warning: Tomcat may not be running properly"
    echo "Check logs at: /opt/tomcat/logs/catalina.out"
    echo "=========================================="
fi

# Show Tomcat status
echo ""
echo "Tomcat process:"
ps aux | grep tomcat | grep -v grep

echo ""
echo "Listening ports:"
sudo ss -tlnp | grep 8080
