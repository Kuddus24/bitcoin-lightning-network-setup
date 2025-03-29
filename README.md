# Bitcoin Core and Lightning Network Daemon (LND) Setup

This repository contains documentation and scripts for setting up a Bitcoin Core node in regtest mode and configuring multiple Lightning Network Daemon (LND) nodes for testing and development purposes.

## Overview

This project demonstrates how to:
- Install and configure Bitcoin Core in regtest mode
- Set up multiple LND nodes
- Create Lightning channels between nodes
- Perform multi-hop payments across the Lightning Network
- Compare Multi-path Payments (MPP) vs Atomic Multi-path Payments (AMP)
- Close Lightning channels

## Prerequisites

- Operating system: Unix-based systems recommended (Ubuntu/Debian used in examples)
- Hardware: Minimum 2GB RAM, 1 GHz quad core, 5GB storage (SSD recommended)
- Bitcoin Core v27.0 or higher
- Go (for LND installation)
- LND v0.13 or higher (for AMP functionality)

## Repository Structure

- `docs/`: Detailed documentation
  - `full-documentation.md`: Complete setup and operation guide
  - `assignment.md`: Original assignment requirements
- `config/`: Configuration files for Bitcoin Core and LND nodes
- `scripts/`: Helper scripts for automating setup and operations
- `images/`: Diagrams and visual aids

## Complete Setup Guide

### Step 1: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/bitcoin-lightning-network-setup.git

# Navigate to the project directory
cd bitcoin-lightning-network-setup
```
### Step 2: Install Prerequisites
For Ubuntu/Debian:
 ```bash
# Update your system
sudo apt update
sudo apt upgrade -y

# Install essential packages
sudo apt install -y git curl jq build-essential

# Install dependencies for Bitcoin Core compilation (if needed)
sudo apt install -y autoconf libtool pkg-config libboost-all-dev libssl-dev libevent-dev
 ```

### Step 3: Install Bitcoin Core
```bash
# Make the script executable
chmod +x scripts/setup_bitcoin.sh

# Run the Bitcoin Core installation script
./scripts/setup_bitcoin.sh
```
This script will:
- Download Bitcoin Core v27.0
- Extract the files
- Install Bitcoin Core to /usr/local/bin/
- Create the configuration directory
- Copy the Bitcoin configuration file


### Step 4: Install Go and LND
```bash
# Make the script executable
chmod +x scripts/setup_lnd.sh

# Run the LND installation script
./scripts/setup_lnd.sh
```

 This script will:
- Download and install Go 1.22.6
- Set up Go environment variables
- Clone and build LND from source
- Create directories for the four LND nodes
- Copy the configuration files for each node


### Step 5: Start Bitcoin Core in Regtest Mode
```bash
# Start Bitcoin Core in regtest mode
bitcoind -regtest -daemon

# Verify that Bitcoin Core is running
bitcoin-cli -regtest getblockchaininfo

```

### Step 6: Set Up Lightning Network Nodes and Channels
```bash
# Make the script executable
chmod +x scripts/create_channels.sh

# Run the script to create nodes and channels
./scripts/create_channels.sh
```


This script will:

- Start all four LND nodes (A, B, C, D)
- Create wallets for each node (you'll need to set passwords and save the recovery seeds)
- Generate Bitcoin addresses for each node
- Mine initial blocks and send funds to each node
- Connect the nodes to form the network topology
- Open channels between:

  - Node A and Node B
  - Node B and Node C
  - Node A and Node D
  - Node D and Node C


### Step 7: Test Multi-hop Payments
```bash
# Make the script executable
chmod +x scripts/payment_routing.sh

# Run the payment routing script
./scripts/payment_routing.sh
```

This script will:

- Generate a payment invoice on Node C
- Pay the invoice from Node A, which will route through other nodes
- Demonstrate Multi-path Payment (MPP) by creating a larger invoice
- Demonstrate Atomic Multi-path Payment (AMP) with another invoice
- Compare the differences between MPP and AMP approaches

Checking Node Status
```bash
# For Node A
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 getinfo

# For Node B
lncli --lnddir=~/lnd-B --network=regtest --rpcserver=localhost:10010 getinfo

# For Node C
lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 getinfo

# For Node D
lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 getinfo
```

Checking Balances
```bash
# For Node A
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 walletbalance

# Check Bitcoin Core balance
bitcoin-cli -regtest getbalance

```

Shutdown
When you're done with testing:
```bash
# Stop LND nodes
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 stop
lncli --lnddir=~/lnd-B --network=regtest --rpcserver=localhost:10010 stop
lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 stop
lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 stop

# Stop Bitcoin Core
bitcoin-cli -regtest stop
```


Logs location:

Bitcoin Core logs: ~/.bitcoin/regtest/debug.log
LND logs for Node A: ~/lnd-A/logs/bitcoin/regtest/lnd.log
