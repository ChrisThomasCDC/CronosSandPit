#!/bin/bash


source /etc/environment
cronosd init ${NODE_NAME:-nonamenode} --chain-id=${CHAIN_ID:-bbteam_1337-1}
export ACCOUNT_NAME=account01
export ACCOUNT_BALANCE=1000000000000000000cro

# Imports An Existing Account
ImportExistingAccount(){
    IMP_ACCOUNT_NAME=$1
    IMP_ACCOUNT_MNEMONIC=$2
	IMP_ACCOUNT_BALANCE=$3
    IMP_KEYRING=$4

	if [ $# != 4 ]; then
		echo "expected 4 arguments for initialize"
		exit 1
	fi # if [ $# != 3 ]; then

    cronosd keys add $IMP_ACCOUNT_NAME --recover --keyring-backend $IMP_KEYRING < <(echo "$IMP_ACCOUNT_MNEMONIC")

    cronosd add-genesis-account $(cronosd keys show $IMP_ACCOUNT_NAME -a --keyring-backend $KEYRING) $IMP_ACCOUNT_BALANCE --keyring-backend $IMP_KEYRING
}# end of ImportExistingAccount(){



# Imports An Existing Account
ImportExistingAccount() {
    IMP_ACCOUNT_NAME=$1
    IMP_ACCOUNT_MNEMONIC=$2
	IMP_ACCOUNT_BALANCE=$3
    IMP_KEYRING=$4

	if [ $# != 4 ]; then
		echo "expected 4 arguments for initialize"
		exit 1
	fi # if [ $# != 3 ]; then

 	echo "Generating Account '$IMP_ACCOUNT_NAME'..."

    cronosd keys add $IMP_ACCOUNT_NAME --recover --keyring-backend $IMP_KEYRING < <(echo "$IMP_ACCOUNT_MNEMONIC")

    cronosd add-genesis-account $(cronosd keys show $IMP_ACCOUNT_NAME -a --keyring-backend $IMP_KEYRING) ${IMP_ACCOUNT_BALANCE:-1000000000000000000}${COIN:-cro} --keyring-backend $IMP_KEYRING

    echo "Finished Generationg Account '$IMP_ACCOUNT_NAME' ..."	

	unset IMP_ACCOUNT_NAME
	unset IMP_ACCOUNT_MNEMONIC
	unset IMP_ACCOUNT_BALANCE
	unset IMP_KEYRING	
} # end of ImportExistingAccount(){




AddAccount() {
	ACCOUNT_NAME=$1
	ACCOUNT_BALANCE=$2
    KEYRING=$3

	if [ $# != 3 ]; then
		echo "expected 3 arguments for initialize"
		exit 1
	fi # if [ $# != 3 ]; then

    echo "Generating Account '$ACCOUNT_NAME'..."

    # create the key inside the keyring, we need to pipe everything to capture the mnemonic
    cronosd keys add $ACCOUNT_NAME --keyring-backend $KEYRING > ~/account_$ACCOUNT_NAME 2>&1

    #Only interested in the mnemonic itself which is the last thing in the file
    cat ~/account_$ACCOUNT_NAME | tail --lines 1 > ~/account_$ACCOUNT_NAME.mnemonic

    #Easy way to get the public address, i can get it from the above file but meh
    cronosd keys show $ACCOUNT_NAME -a --keyring-backend $KEYRING > ~/account_$ACCOUNT_NAME.address 2>&1

    #This seems new and fun!  export priv key for use elsewhere
    cronosd keys unsafe-export-eth-key $ACCOUNT_NAME --keyring-backend $KEYRING > ~/account_$ACCOUNT_NAME.privkey 2>&1

    # Add details to the chain
    cronosd add-genesis-account $(cronosd keys show $ACCOUNT_NAME -a --keyring-backend $KEYRING) ${ACCOUNT_BALANCE:-1000000000000000000}${COIN:-cro} --keyring-backend $KEYRING

    echo -e "$ACCOUNT_NAME,`cat account_account01.address`,$ACCOUNT_BALANCE,`cat account_account01.privkey`,`cat account_account01.mnemonic`\n"   >> ~/accounts.csv

    echo "Finished Generationg Account '$ACCOUNT_NAME' ..."
}#End of AddAccount
