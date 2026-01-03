#!/bin/bash

# Tomcat 11.0.15 Production Installation Script

set -e

TOMCAT_VERSION="11.0.15"
TOMCAT_ZIP="apache-tomcat-${TOMCAT_VERSION}.zip"
TOMCAT_DIR="apache-tomcat-${TOMCAT_VERSION}"
INSTALL_DIR="/opt/tomcat"

echo "=========================================="
echo "Starting Tomcat ${TOMCAT_VERSION} Installation"
echo "=========================================="

# Update system
echo "Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# Install Java (Tomcat 11 requires Java 17+)
echo "Installing OpenJDK 25..."
sudo apt install -y openjdk-25-jdk unzip curl

# Download Tomcat
echo "Downloading Tomcat..."
cd /opt
sudo wget -q https://dlcdn.apache.org/tomcat/tomcat-11/v${TOMCAT_VERSION}/bin/${TOMCAT_ZIP}

# Extract
echo "Extracting Tomcat..."
sudo unzip -q ${TOMCAT_ZIP}
sudo mv ${TOMCAT_DIR} tomcat

# Remove ZIP (cleanup)
echo "Removing installation ZIP..."
sudo rm -f ${TOMCAT_ZIP}

# Create tomcat user/group
echo "Creating tomcat user and group..."
sudo groupadd tomcat 2>/dev/null || true
sudo useradd -s /bin/false -g tomcat -d ${INSTALL_DIR} tomcat 2>/dev/null || true

# Permissions
echo "Setting permissions..."
sudo chown -R tomcat:tomcat ${INSTALL_DIR}
sudo chmod +x ${INSTALL_DIR}/bin/*.sh

# ==============================
# Production Cleanup (IMPORTANT)
# ==============================

echo "Removing default web applications..."
sudo rm -rf \
  ${INSTALL_DIR}/webapps/docs \
  ${INSTALL_DIR}/webapps/examples \
  ${INSTALL_DIR}/webapps/manager \
  ${INSTALL_DIR}/webapps/host-manager

echo "Removing default ROOT app (deploy your own)..."
sudo rm -rf ${INSTALL_DIR}/webapps/ROOT
sudo rm -f  ${INSTALL_DIR}/webapps/ROOT.war

echo "Cleaning temp and work directories..."
sudo rm -rf ${INSTALL_DIR}/temp/*
sudo rm -rf ${INSTALL_DIR}/work/*

echo "Removing Windows .bat files..."
sudo rm -f ${INSTALL_DIR}/bin/*.bat

# Start Tomcat
echo "Starting Tomcat..."
sudo -u tomcat ${INSTALL_DIR}/bin/startup.sh

# Wait for startup
sleep 5

# Test Tomcat
echo "Testing Tomcat..."
if curl -s http://localhost:8080 > /dev/null; then
    echo "=========================================="
    echo "✓ Tomcat installation successful"
    echo "✓ Running on port 8080"
    echo "=========================================="
else
    echo "=========================================="
    echo "✗ Tomcat may not be running"
    echo "Check logs: ${INSTALL_DIR}/logs/catalina.out"
    echo "=========================================="
fi

# Status
echo ""
echo "Tomcat process:"
ps aux | grep tomcat | grep -v grep

echo ""
echo "Listening ports:"
sudo ss -tlnp | grep 8080
