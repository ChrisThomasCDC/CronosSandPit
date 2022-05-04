#!/bin/bash

#https://github.com/tharsis/evmos/blob/main/init.sh


#Load Environment Variables
source /etc/environment

echo "Chain ID: '$CHAINID' ($NODE_NAME)"
echo "Account Name: '$KEY' (Keyring: '$KEYRING')"



if [ ! -v NODE_MODE ]
  then
    export NODE_MODE='SOLO'
fi



####  CREATES A NEW NETWORK FROM SCRATCH, YOU JUST NEED A BLANK DATA DIR
########################################################################################################################################
########################################################################################################################################


if [ "$NODE_MODE" = "SOLO" ]; then
# https://cronos.org/docs/getting-started/local-devnet.html#step-1-customize-your-devnet

echo "We are going 'SOLO', Cleaning Up My Data Dir's "
rm -rf ~/.cronos

echo "moo1"

# Setting up the network name and chain ID
cronosd config keyring-backend $KEYRING
cronosd config chain-id $CHAINID

echo "moo2"

# Create new set of cronos keys
#[CT Mat22] dumping out the account nmemonic for use elsewhere
cronosd keys add $KEY --keyring-backend $KEYRING  > ~/account_mnemonic.txt 2>&1

echo "moo3"

# create the genesis file and and init the validator/node config
cronosd init $NODE_NAME --chain-id $CHAINID

echo "moo4"

# Allocate genesis accounts (cosmos formatted addresses)
#cronosd add-genesis-account $(cronosd keys show $KEY -a) 10000000000000stake,100000000000000000000000000basecro --keyring-backend $KEYRING
cronosd add-genesis-account $(cronosd keys show $KEY -a) 100000000000000000000000000basecro --keyring-backend $KEYRING

echo "moo5"

#[CT - May 22] this is a devnet box for pwning, increase block time to now spam so often.
cat ~/.cronos/config/config.toml | sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' ~/.cronos/config/config.toml

if [[ "$EMPTY_BLOCKS" == "true" ]]; then
    cat ~/.cronos/config/config.toml | sed -i 's/create_empty_blocks = false/create_empty_blocks = true/g' ~/.cronos/config/config.toml    
  else
    cat ~/.cronos/config/config.toml | sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' ~/.cronos/config/config.toml
fi

# Change parameter token denominations to basecro
cat ~/.cronos/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="basecro"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
cat ~/.cronos/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="basecro"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
cat ~/.cronos/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="basecro"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
cat ~/.cronos/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="basecro"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
cat ~/.cronos/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="basecro"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
cat ~/.cronos/config/genesis.json | jq '.app_state["inflation"]["params"]["mint_denom"]="basecro"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json


echo "moo6"

# Sign genesis transaction
cronosd gentx $KEY 10000000000000000000basecro --keyring-backend $KEYRING --chain-id $CHAINID

echo "moo7"

# Collect genesis tx
cronosd collect-gentxs

echo "moo8"

# Run this to ensure everything worked and that the genesis file is setup correctly
cronosd validate-genesis

echo "moo9"

if [[ $1 == "pending" ]]; then
  echo "pending mode is on, please wait for the first block committed."
fi

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
cronosd start --pruning=nothing $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0.0001basecro --json-rpc.api eth,txpool,personal,net,debug,web3

echo "moo10"

fi


if [ "$NODE_MODE" = "SHELL" ]; then
/bin/bash
fi

