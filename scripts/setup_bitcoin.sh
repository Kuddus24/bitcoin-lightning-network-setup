#!/bin/bash

# Script to download and install Bitcoin Core

echo "Installing Bitcoin Core..."

# Download Bitcoin Core
wget https://bitcoincore.org/bin/bitcoin-core-27.0/bitcoin-27.0-x86_64-linux-gnu.tar.gz

# Verify download exists
if [ ! -f bitcoin-27.0-x86_64-linux-gnu.tar.gz ]; then
    echo "Download failed. Exiting."
    exit 1
fi

# Extract Bitcoin Core
tar -xvzf bitcoin-27.0-x86_64-linux-gnu.tar.gz

# Move binaries to /usr/local/bin/
sudo mv bitcoin-27.0/bin/* /usr/local/bin/

# Verify installation
if command -v bitcoind &> /dev/null; then
    echo "Bitcoin Core installed successfully."
    bitcoind --version
else
    echo "Installation failed."
    exit 1
fi

# Create configuration directory if it doesn't exist
mkdir -p ~/.bitcoin

# Copy bitcoin.conf
if [ -f config/bitcoin.conf ]; then
    cp config/bitcoin.conf ~/.bitcoin/
    echo "Bitcoin configuration copied to ~/.bitcoin/"
else
    echo "Bitcoin configuration file not found. Please create one manually."
fi

echo "Bitcoin Core installation complete."
