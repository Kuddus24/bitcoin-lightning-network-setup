#!/bin/bash

# Script to demonstrate payment routing in the Lightning Network
# This script shows how to perform multi-hop payments and compares MPP vs AMP

echo "Setting up for payment routing demonstration..."

# Get Node C's pubkey
PUBKEY_C=$(lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 getinfo | jq -r '.identity_pubkey')

echo "Generating a standard invoice on Node C (destination)..."
STANDARD_INVOICE=$(lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 addinvoice --memo="Test Payment" --amt=150000 | jq -r '.payment_request')
PAYMENT_HASH=$(lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 addinvoice --memo="Test Payment" --amt=150000 | jq -r '.r_hash')

echo "Generated invoice: $STANDARD_INVOICE"
echo "Payment hash: $PAYMENT_HASH"

echo "Paying invoice from Node A (source) to Node C (destination)..."
echo "This will demonstrate multi-hop payment routing..."
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 payinvoice $STANDARD_INVOICE

echo "Monitoring payment status..."
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 trackpayment $PAYMENT_HASH

echo "Checking channels after payment..."
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 listchannels
lncli --lnddir=~/lnd-B --network=regtest --rpcserver=localhost:10010 listchannels
lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 listchannels
lncli --lnddir=~/lnd-D --network=regtest --rpcserver=localhost:10012 listchannels

# Demonstrate Multi-path Payment (MPP)
echo "Demonstrating Multi-path Payment (MPP)..."
echo "Generating a larger invoice on Node C that should require multiple paths..."
MPP_INVOICE=$(lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 addinvoice --memo="MPP Test" --amt=1500000 | jq -r '.payment_request')
MPP_HASH=$(lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 addinvoice --memo="MPP Test" --amt=1500000 | jq -r '.r_hash')

echo "Attempting to pay the large invoice from Node A..."
echo "This should automatically split into multiple paths (MPP)..."
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 payinvoice $MPP_INVOICE

echo "Monitoring MPP status..."
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 trackpayment $MPP_HASH

# Demonstrate Atomic Multi-path Payment (AMP)
echo "Demonstrating Atomic Multi-path Payment (AMP)..."
echo "Checking LND version to ensure AMP support..."
lncli --version

echo "Generating an AMP invoice on Node C..."
AMP_INVOICE=$(lncli --lnddir=~/lnd-C --network=regtest --rpcserver=localhost:10011 addinvoice --amp --amt=15000000 --memo="AMP Payment" | jq -r '.payment_request')

echo "Paying the AMP invoice from Node A..."
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 payinvoice $AMP_INVOICE --amp

echo "Checking payment list to see all completed payments..."
lncli --lnddir=~/lnd-A --network=regtest --rpcserver=localhost:10009 listpayments

echo "Payment routing demonstration complete!"
echo ""
echo "Key differences between MPP and AMP:"
echo "1. MPP: All shards use the same payment hash (correlatable routes, risk of partial settlement)"
echo "2. AMP: Atomic settlement - either all shards are settled or none"
echo "3. AMP: Allows payments by only knowing recipient's public key"
echo "4. AMP: Enables reusable invoices for subscriptions or donations"
