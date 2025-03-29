#!/bin/bash

# Script to install Go and LND

echo "Installing Go..."

# Download Go
wget https://dl.google.com/go/go1.22.6.linux-amd64.tar.gz

# Extract Go
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.6.linux-amd64.tar.gz

# Set environment variables
export PATH=$PATH:/usr/local/go/bin
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin

# Add to .bashrc for persistence
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=~/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc

# Verify Go installation
go version

echo "Installing LND..."

# Clone LND repository
git clone https://github.com/lightningnetwork/lnd
cd lnd

# Build and install LND
make install

# Verify installation
if command -v lnd &> /dev/null; then
    echo "LND installed successfully."
    lnd --version
else
    echo "LND installation failed."
    exit 1
fi

# Create directories for LND nodes
mkdir -p ~/lnd-A ~/lnd-B ~/lnd-C ~/lnd-D

# Copy configuration files
if [ -d ../config ]; then
    cp ../config/lnd-a.conf ~/lnd-A/lnd.conf
    cp ../config/lnd-b.conf ~/lnd-B/lnd.conf
    cp ../config/lnd-c.conf ~/lnd-C/lnd.conf
    cp ../config/lnd-d.conf ~/lnd-D/lnd.conf
    echo "LND configurations copied to respective directories."
else
    echo "Configuration files not found. Please create them manually."
fi

echo "LND installation complete."
