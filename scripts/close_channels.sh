#!/bin/bash

# Script to close Lightning Network channels and return funds to Bitcoin wallet

echo "Preparing to close Lightning Network channels..."

# Function to get channel point for a node
get_channel_point() {
    local lnd_dir=$1
    local rpc_port=$2
    local counterparty_pubkey=$3
    
    channel_point=$(lncli --lnddir=$lnd_dir --network=regtest --rpcserver=localhost:$rpc_port listchannels | \
                   jq --arg pubkey "$counterparty_pubkey" '.channels[] | select(.remote_pubkey==$pubkey) | .channel_point' | \
                   tr -d '"')
    
    echo $channel_point
}

# Get pubkeys for each node
PUBKEY_A=$(lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 getinfo | jq -r '.identity_pubkey')
PUBKEY_B=$(lncli --lnddir=~/lnd-B --network=regtest --rpcserver=localhost:10010 getinfo | jq -r '.identity_pubkey')
PUBKEY_C=$(lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 getinfo | jq -r '.identity_pubkey')
PUBKEY_D=$(lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 getinfo | jq -r '.identity_pubkey')

echo "Retrieved node public keys:"
echo "Node A: $PUBKEY_A"
echo "Node B: $PUBKEY_B"
echo "Node C: $PUBKEY_C"
echo "Node D: $PUBKEY_D"

# Close channel between Node A and Node B
echo "Closing channel between Node A and Node B..."
CHANNEL_AB=$(get_channel_point ~/lnd-A 10009 $PUBKEY_B)

if [ -n "$CHANNEL_AB" ]; then
    echo "Found channel point: $CHANNEL_AB"
    FUNDING_TXID_A=$(echo $CHANNEL_AB | cut -d':' -f1)
    OUTPUT_INDEX_A=$(echo $CHANNEL_AB | cut -d':' -f2)
    
    echo "Closing channel with funding txid: $FUNDING_TXID_A and output index: $OUTPUT_INDEX_A"
    lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 closechannel --funding_txid=$FUNDING_TXID_A --output_index=$OUTPUT_INDEX_A
else
    echo "No channel found between Node A and Node B"
fi

# Mine some blocks to confirm the channel closure
echo "Mining blocks to confirm channel closure..."
MINER_ADDR=$(bitcoin-cli -regtest getnewaddress)
bitcoin-cli -regtest generatetoaddress 6 $MINER_ADDR

# Close channel between Node D and Node C
echo "Closing channel between Node D and Node C..."
CHANNEL_DC=$(get_channel_point ~/lnd-D 10012 $PUBKEY_C)

if [ -n "$CHANNEL_DC" ]; then
    echo "Found channel point: $CHANNEL_DC"
    FUNDING_TXID_D=$(echo $CHANNEL_DC | cut -d':' -f1)
    OUTPUT_INDEX_D=$(echo $CHANNEL_DC | cut -d':' -f2)
    
    echo "Closing channel with funding txid: $FUNDING_TXID_D and output index: $OUTPUT_INDEX_D"
    lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 closechannel --funding_txid=$FUNDING_TXID_D --output_index=$OUTPUT_INDEX_D
else
    echo "No channel found between Node D and Node C"
fi

# Mine more blocks to confirm the second channel closure
echo "Mining additional blocks to confirm all channel closures..."
bitcoin-cli -regtest generatetoaddress 10 $MINER_ADDR

echo "Verifying channel closures..."
echo "Node A channels:"
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 listchannels

echo "Node B channels:"
lncli --lnddir=~/lnd-B --network=regtest --rpcserver=localhost:10010 listchannels

echo "Node C channels:"
lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 listchannels

echo "Node D channels:"
lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 listchannels

echo "Checking wallet balances after channel closures..."
echo "Node A balance:"
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 walletbalance

echo "Node D balance:"
lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 walletbalance

echo "Bitcoin wallet balance:"
bitcoin-cli -regtest getbalance

echo "Channel closing process completed."
echo "Funds should have been returned to the respective Bitcoin wallets."
