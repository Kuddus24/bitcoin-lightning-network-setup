#!/bin/bash

# Script to create Lightning Network channels between nodes

echo "Starting Bitcoin Core in regtest mode..."
bitcoind -regtest -daemon

# Wait for Bitcoin Core to start
sleep 5

echo "Starting LND nodes..."
lnd --lnddir=~/lnd-A --configfile=~/lnd-A/lnd.conf &
sleep 2
lnd --lnddir=~/lnd-B --configfile=~/lnd-B/lnd.conf &
sleep 2
lnd --lnddir=~/lnd-C --configfile=~/lnd-C/lnd.conf &
sleep 2
lnd --lnddir=~/lnd-D --configfile=~/lnd-D/lnd.conf &
sleep 2

echo "Creating wallets for each node..."
echo "Please follow the prompts to create wallets for each node."
echo "For each node, you will need to set a password and save the recovery seed."

echo "Creating wallet for node A..."
lncli --lnddir=~/lnd-A --rpcserver=localhost:10009 create

echo "Creating wallet for node B..."
lncli --lnddir=~/lnd-B --rpcserver=localhost:10010 create

echo "Creating wallet for node C..."
lncli --lnddir=~/lnd-C --rpcserver=localhost:10011 create

echo "Creating wallet for node D..."
lncli --lnddir=~/lnd-D --rpcserver=localhost:10012 create

echo "Generating addresses for each node..."
ADDR_A=$(lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 newaddress p2wkh | jq -r '.address')
ADDR_B=$(lncli --lnddir=~/lnd-B --network=regtest --rpcserver=localhost:10010 newaddress p2wkh | jq -r '.address')
ADDR_C=$(lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 newaddress p2wkh | jq -r '.address')
ADDR_D=$(lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 newaddress p2wkh | jq -r '.address')

echo "Mining initial blocks..."
MINER_ADDR=$(bitcoin-cli -regtest getnewaddress)
bitcoin-cli -regtest generatetoaddress 200 $MINER_ADDR

echo "Sending funds to LND nodes..."
bitcoin-cli -regtest sendtoaddress $ADDR_A 20
bitcoin-cli -regtest sendtoaddress $ADDR_B 20
bitcoin-cli -regtest sendtoaddress $ADDR_C 20
bitcoin-cli -regtest sendtoaddress $ADDR_D 20

echo "Mining additional blocks to confirm transactions..."
bitcoin-cli -regtest generatetoaddress 6 $MINER_ADDR

echo "Connecting nodes..."
# Get Node B's pubkey
PUBKEY_B=$(lncli --lnddir=~/lnd-B --network=regtest --rpcserver=localhost:10010 getinfo | jq -r '.identity_pubkey')
# Get Node C's pubkey
PUBKEY_C=$(lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 getinfo | jq -r '.identity_pubkey')
# Get Node D's pubkey
PUBKEY_D=$(lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 getinfo | jq -r '.identity_pubkey')

# Connect A to B
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 connect $PUBKEY_B@127.0.0.1:9736

# Connect B to C
lncli --lnddir=~/lnd-B --network=regtest --rpcserver=localhost:10010 connect $PUBKEY_C@127.0.0.1:9737

# Connect A to D
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 connect $PUBKEY_D@127.0.0.1:9738

# Connect D to C
lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 connect $PUBKEY_C@127.0.0.1:9737

echo "Opening channels..."
# Open channel from A to B
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 openchannel --node_key=$PUBKEY_B --local_amt=100000

# Wait for channel to be created
sleep 5
bitcoin-cli -regtest generatetoaddress 6 $MINER_ADDR
sleep 5

# Open channel from B to C
lncli --lnddir=~/lnd-B --network=regtest --rpcserver=localhost:10010 openchannel --node_key=$PUBKEY_C --local_amt=100000

# Wait for channel to be created
sleep 5
bitcoin-cli -regtest generatetoaddress 6 $MINER_ADDR
sleep 5

# Open channel from A to D
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 openchannel --node_key=$PUBKEY_D --local_amt=100000

# Wait for channel to be created
sleep 5
bitcoin-cli -regtest generatetoaddress 6 $MINER_ADDR
sleep 5

# Open channel from D to C
lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 openchannel --node_key=$PUBKEY_C --local_amt=100000

# Confirm all channels
sleep 5
bitcoin-cli -regtest generatetoaddress 6 $MINER_ADDR

echo "Checking channel status..."
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 listchannels
lncli --lnddir=~/lnd-B --network=regtest --rpcserver=localhost:10010 listchannels
lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 listchannels
lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 listchannels

echo "Lightning Network setup complete!"
