#!/bin/bash


# Reference (Prior Works)
#https://github.com/RyanHendricks/docker-regen/blob/master/scripts/entrypoint.sh  <- This Author heavily inspired below
#https://github.com/tharsis/evmos/blob/main/init.sh

#Exit script on any error
set -e

#Load Environment Variables
source /etc/environment

write_client_toml() {
	cat >client.toml <<EOF
# This is a TOML config file.
# For more information, see https://github.com/toml-lang/toml
###############################################################################
###                           Client Configuration                            ###
###############################################################################
# The network chain ID
chain-id = "${CHAIN_ID:-}"
# The keyring's backend, where the keys are stored (os|file|kwallet|pass|test|memory)
keyring-backend = "${KEYRING_BACKEND:-os}"
# CLI output format (text|json)
output = "${CLI_OUTPUT_FORMAT:-text}"
# <host>:<port> to Tendermint RPC interface for this chain
node = "tcp://localhost:26657"
# Transaction broadcasting mode (sync|async|block)
broadcast-mode = "${BROADCAST_MODE:-sync}"
EOF
}


write_config_toml() {
	cat >config.toml <<EOF
# This is a TOML config file.
# For more information, see https://github.com/toml-lang/toml
# NOTE: Any path below can be absolute (e.g. "/var/myawesomeapp/data") or
# relative to the home directory (e.g. "data"). The home directory is
# "$HOME/.tendermint" by default, but could be changed via $TMHOME env variable
# or --home cmd flag.
#######################################################################
###                   Main Base Config Options                      ###
#######################################################################
# TCP or UNIX socket address of the ABCI application,
# or the name of an ABCI application compiled in with the Tendermint binary
proxy_app = "${PROXY_APP_LADDR:-tcp://0.0.0.0}:${PROXY_APP_PORT:-26658}"
# A custom human readable name for this node
moniker = "${NODE_NAME:-moniker}"
# If this node is many blocks behind the tip of the chain, FastSync
# allows them to catchup quickly by downloading blocks in parallel
# and verifying their commits
fast_sync = ${FAST_SYNC:-true}
# Database backend: leveldb | memdb | cleveldb
db_backend = "${DB_BACKEND:-goleveldb}"
# Database directory
db_dir = "${DB_DIR:-data}"
# Output level for logging, including package level options
log_level = "${LOG_LEVEL:-error}"
log_format = "${LOG_FORMAT:-plain}"
##### additional base config options #####
# Path to the JSON file containing the initial validator set and other meta data
genesis_file = "${GENESIS_FILE:-config/genesis.json}"
# Path to the JSON file containing the private key to use as a validator in the consensus protocol
priv_validator_key_file = "${PRIV_VALIDATOR_KEY_FILE:-config/priv_validator_key.json}"
# Path to the JSON file containing the last sign state of a validator
priv_validator_state_file = "${PRIV_VALIDATOR_KEY_FILE:-data/priv_validator_state.json}"
# TCP or UNIX socket address for Tendermint to listen on for
# connections from an external PrivValidator process
priv_validator_laddr = "${PRIV_VALIDATOR_LADDR:-}"
# Path to the JSON file containing the private key to use for node authentication in the p2p protocol
node_key_file = "${NODE_KEY_FILE:-config/node_key.json}"
# Mechanism to connect to the ABCI application: socket | grpc
abci = "${ABCI:-socket}"
# If true, query the ABCI app on connecting to a new peer
# so the app can decide if we should keep the connection or not
filter_peers = ${FILTER_PEERS:-false}
#######################################################################
###                 Advanced Configuration Options                  ###
#######################################################################
#######################################################
###       RPC Server Configuration Options          ###
#######################################################
[rpc]
# TCP or UNIX socket address for the RPC server to listen on
laddr = "${RPC_LADDR:-tcp://0.0.0.0}:${RPC_PORT:-26657}"
# A list of origins a cross-domain request can be executed from
# Default value '[]' disables cors support
# Use '["*"]' to allow any origin
cors_allowed_origins = ["*"]
# A list of methods the client is allowed to use with cross-domain requests
cors_allowed_methods = ["HEAD", "GET", "POST"]
# A list of non simple headers the client is allowed to use with cross-domain requests
cors_allowed_headers = ["Origin", "Accept", "Content-Type", "X-Requested-With", "X-Server-Time"]
# TCP or UNIX socket address for the gRPC server to listen on
# NOTE: This server only supports /broadcast_tx_commit
grpc_laddr = "${GRPC_LADDR:-}"
# Maximum number of simultaneous connections.
# Does not include RPC (HTTP&WebSocket) connections. See max_open_connections
# If you want to accept a larger number than the default, make sure
# you increase your OS limits.
# 0 - unlimited.
# Should be < {ulimit -Sn} - {MaxNumInboundPeers} - {MaxNumOutboundPeers} - {N of wal, db and other open files}
# 1024 - 40 - 10 - 50 = 924 = ~900
grpc_max_open_connections = ${GRPC_MAX_OPEN_CONNECTIONS:-900}
# Activate unsafe RPC commands like /dial_seeds and /unsafe_flush_mempool
unsafe = ${UNSAFE:-false}
# Maximum number of simultaneous connections (including WebSocket).
# Does not include gRPC connections. See grpc_max_open_connections
# If you want to accept a larger number than the default, make sure
# you increase your OS limits.
# 0 - unlimited.
# Should be < {ulimit -Sn} - {MaxNumInboundPeers} - {MaxNumOutboundPeers} - {N of wal, db and other open files}
# 1024 - 40 - 10 - 50 = 924 = ~900
max_open_connections = ${RPC_MAX_OPEN_CONNECTIONS:-900}
# Maximum number of unique clientIDs that can /subscribe
# If you're using /broadcast_tx_commit, set to the estimated maximum number
# of broadcast_tx_commit calls per block.
max_subscription_clients = ${MAX_SUBSCRIPTION_CLIENTS:-100}
# Maximum number of unique queries a given client can /subscribe to
# If you're using GRPC (or Local RPC client) and /broadcast_tx_commit, set to
# the estimated # maximum number of broadcast_tx_commit calls per block.
max_subscriptions_per_client = ${MAX_SUBSCRIPTION_PER_CLIENT:-5}
# How long to wait for a tx to be committed during /broadcast_tx_commit.
# WARNING: Using a value larger than 10s will result in increasing the
# global HTTP write timeout, which applies to all connections and endpoints.
# See https://github.com/tendermint/tendermint/issues/3435
timeout_broadcast_tx_commit = "${TIMEOUT_BROADCAST_TX_COMMIT:-10s}"
# Maximum size of request body, in bytes
max_body_bytes = ${MAX_SIZE_REQUEST_BODY:-1000000}
# Maximum size of request header, in bytes
max_header_bytes = ${MAX_SIZE_REQUEST_HEADER:-1048576}
# The path to a file containing certificate that is used to create the HTTPS server.
# Might be either absolute path or path related to Tendermint's config directory.
# If the certificate is signed by a certificate authority,
# the certFile should be the concatenation of the server's certificate, any intermediates,
# and the CA's certificate.
# NOTE: both tls_cert_file and tls_key_file must be present for Tendermint to create HTTPS server.
# Otherwise, HTTP server is run.
tls_cert_file = "${TLS_CERT_FILE:-}"
# The path to a file containing matching private key that is used to create the HTTPS server.
# Might be either absolute path or path related to Tendermint's config directory.
# NOTE: both tls-cert-file and tls-key-file must be present for Tendermint to create HTTPS server.
# Otherwise, HTTP server is run.
tls_key_file = "${TLS_KEY_FILE:-}"
# pprof listen address (https://golang.org/pkg/net/http/pprof)
prof_laddr = "${PROF_LADDR:-localhost:6060}"
#######################################################
###           P2P Configuration Options             ###
#######################################################
[p2p]
# Address to listen for incoming connections
laddr = "${P2P_LADDR:-tcp://0.0.0.0}:${P2P_PORT:-26656}"
# Address to advertise to peers for them to dial
# If empty, will use the same port as the laddr,
# and will introspect on the listener or use UPnP
# to figure out the address.
external_address = "${EXTERNAL_ADDRESS:-}"
# Comma separated list of seed nodes to connect to
seeds = "${SEEDS:-}"
# Comma separated list of nodes to keep persistent connections to
persistent_peers = "${PERSISTENT_PEERS:-}"
# UPNP port forwarding
upnp = ${UPNP:-false}
# Path to address book
addr_book_file = "${ADDR_BOOK_FILE:-config/addrbook.json}"
# Set true for strict address routability rules
# Set false for private or local networks
addr_book_strict = ${ADDR_BOOK_STRICT:-true}
# Maximum number of inbound peers
max_num_inbound_peers = ${MAX_NUM_INBOUND_PEERS:-40}
# Maximum number of outbound peers to connect to, excluding persistent peers
max_num_outbound_peers = ${MAX_NUM_OUTBOUND_PEERS:-10}
# List of node IDs, to which a connection will be (re)established ignoring any existing limits
unconditional_peer_ids = "${UNCONDITIONAL_PEER_IDS:-}"
# Maximum pause when redialing a persistent peer (if zero, exponential backoff is used)
persistent_peers_max_dial_period = "${PERSISTENT_PEERS_MAX_DIAL_PERIOD:-0s}"
# Time to wait before flushing messages out on the connection
flush_throttle_timeout = "${FLUSH_THROTTLE_TIMEOUT:-100ms}"
# Maximum size of a message packet payload, in bytes
max_packet_msg_payload_size = ${MAX_PACKET_MSG_PAYLOAD_SIZE:-1024}
# Rate at which packets can be sent, in bytes/second
send_rate = ${SEND_RATE:-5120000}
# Rate at which packets can be received, in bytes/second
recv_rate = ${RECV_RATE:-5120000}
# Set true to enable the peer-exchange reactor
pex = ${PEX:-true}
# Seed mode, in which node constantly crawls the network and looks for
# peers. If another node asks it for addresses, it responds and disconnects.
#
# Does not work if the peer-exchange reactor is disabled.
seed_mode = ${SEED_MODE:-false}
# Comma separated list of peer IDs to keep private (will not be gossiped to other peers)
private_peer_ids = "${PRIVATE_PEER_IDS:-}"
# Toggle to disable guard against peers connecting from the same ip.
allow_duplicate_ip = ${ALLOW_DUPLICATE_IP:-false}
# Peer connection configuration.
handshake_timeout = "${HANDSHAKE_TIMEOUT:-20s}"
dial_timeout = "${DIAL_TIMEOUT:-3s}"
#######################################################
###          Mempool Configuration Option          ###
#######################################################
[mempool]
recheck = ${RECHECK:-true}
broadcast = ${BROADCAST:-true}
wal_dir = "${WAL_DIR}"
# Maximum number of transactions in the mempool
size = ${SIZE_OF_MEMPOOL:-5000}
# Limit the total size of all txs in the mempool.
# This only accounts for raw transactions (e.g. given 1MB transactions and
# max_txs_bytes=5MB, mempool will only accept 5 transactions).
max_txs_bytes = ${MAX_TXS_BYTES:-1073741824}
# Size of the cache (used to filter transactions we saw earlier) in transactions
cache_size = ${CACHE_SIZE:-10000}
# Do not remove invalid transactions from the cache (default: false)
# Set to true if it's not possible for any invalid transaction to become valid
# again in the future.
keep-invalid-txs-in-cache = false
# Maximum size of a single transaction.
# NOTE: the max size of a tx transmitted over the network is {max_tx_bytes}.
max_tx_bytes = ${MAX_TX_BYTES:-1048576}
# Maximum size of a batch of transactions to send to a peer
# Including space needed by encoding (one varint per transaction).
# XXX: Unused due to https://github.com/tendermint/tendermint/issues/5796
max_batch_bytes = ${MAX_BATCH_BYTES:-0}
#######################################################
###         State Sync Configuration Options        ###
#######################################################
[statesync]
# State sync rapidly bootstraps a new node by discovering, fetching, and restoring a state machine
# snapshot from peers instead of fetching and replaying historical blocks. Requires some peers in
# the network to take and serve state machine snapshots. State sync is not attempted if the node
# has any local state (LastBlockHeight > 0). The node will have a truncated block history,
# starting from the height of the snapshot.
enable = ${STATE_SYNC_ENABLE:-false}
# RPC servers (comma-separated) for light client verification of the synced state machine and
# retrieval of state data for node bootstrapping. Also needs a trusted height and corresponding
# header hash obtained from a trusted source, and a period during which validators can be trusted.
#
# For Cosmos SDK-based chains, trust_period should usually be about 2/3 of the unbonding time (~2
# weeks) during which they can be financially punished (slashed) for misbehavior.
rpc_servers = ""
trust_height = 0
trust_hash = ""
trust_period = "168h0m0s"
# Time to spend discovering snapshots before initiating a restore.
discovery_time = "15s"
# Temporary directory for state sync snapshot chunks, defaults to the OS tempdir (typically /tmp).
# Will create a new, randomly named directory within, and remove it when done.
temp_dir = ""
#######################################################
###       Fast Sync Configuration Connections       ###
#######################################################
[fastsync]
# Fast Sync version to use:
#   1) "v0" (default) - the legacy fast sync implementation
#   2) "v1" - refactor of v0 version for better testability
#   2) "v2" - complete redesign of v0, optimized for testability & readability
version = "${FAST_SYNC_VERSION:-v0}"
#######################################################
###         Consensus Configuration Options         ###
#######################################################
[consensus]
wal_file = "${WAL_FILE:-data/cs.wal/wal}"
timeout_propose = "${TIMEOUT_PROPOSE:-3s}"
timeout_propose_delta = "${TIMEOUT_PROPOSE_DELTA:-500ms}"
timeout_prevote = "${TIMEOUT_PREVOTE:-1s}"
timeout_prevote_delta = "${TIMEOUT_PREVOTE_DELTA:-500ms}"
timeout_precommit = "${TIMEOUT_PRECOMMIT:-1s}"
timeout_precommit_delta = "${TIMEOUT_PRECOMMIT_DELTA:-500ms}"
timeout_commit = "${TIMEOUT_COMMIT:-5s}"
# How many blocks to look back to check existence of the node's consensus votes before joining consensus
# When non-zero, the node will panic upon restart
# if the same consensus key was used to sign {double_sign_check_height} last blocks.
# So, validators should stop the state machine, wait for some blocks, and then restart the state machine to avoid panic.
double_sign_check_height = ${DOUBLE_SIGN_CHECK_HEIGHT:-0}
# Make progress as soon as we have all the precommits (as if TimeoutCommit = 0)
skip_timeout_commit = ${SKIP_TIMEOUT_COMMIT:-false}
# EmptyBlocks mode and possible interval between empty blocks
create_empty_blocks = ${CREATE_EMPTY_BLOCKS:-true}
create_empty_blocks_interval = "${CREATE_EMPTY_BLOCKS_INTERVAL:-0s}"
# Reactor sleep duration parameters
peer_gossip_sleep_duration = "${PEER_GOSSIP_SLEEP_DURATION:-100ms}"
peer_query_maj23_sleep_duration = "${PEER_QUERY_MAJ23_SLEEP_DURATION:-2s}"
#######################################################
###   Transaction Indexer Configuration Options     ###
#######################################################
[tx_index]
# What indexer to use for transactions
#
# The application will set which txs to index. In some cases a node operator will be able
# to decide which txs to index based on configuration set in the application.
#
# Options:
#   1) "null"
#   2) "kv" (default) - the simplest possible indexer, backed by key-value storage (defaults to levelDB; see DBBackend).
# 		- When "kv" is chosen "tx.height" and "tx.hash" will always be indexed.
indexer = "${INDEXER_SELECTION:-kv}"
#######################################################
###       Instrumentation Configuration Options     ###
#######################################################
[instrumentation]
# When true, Prometheus metrics are served under /metrics on
# PrometheusListenAddr.
# Check out the documentation for the list of available metrics.
prometheus = ${PROMETHEUS:-false}
# Address to listen for Prometheus collector(s) connections
prometheus_listen_addr = ":${PROMETHEUS_LISTEN_ADDR:-26660}"
# Maximum number of simultaneous connections.
# If you want to accept a larger number than the default, make sure
# you increase your OS limits.
# 0 - unlimited.
max_open_connections = ${MAX_OPEN_CONNECTIONS:-3}
# Instrumentation namespace
namespace = "${INSTRUMENTATION_NAMESPACE:-tendermint}"
EOF
}

write_app_toml() {
	cat >app.toml <<EOF
# This is a TOML config file.
# For more information, see https://github.com/toml-lang/toml
###############################################################################
###                           Base Configuration                            ###
###############################################################################
# The minimum gas prices a validator is willing to accept for processing a
# transaction. A transaction's fees must meet the minimum of any denomination
# specified in this config (e.g. 0.25token1;0.0001token2).
minimum-gas-prices = "${MINIMUM_GAS_PRICES:-}"
# default: the last 100 states are kept in addition to every 500th state; pruning at 10 block intervals
# nothing: all historic states will be saved, nothing will be deleted (i.e. archiving node)
# everything: all saved states will be deleted, storing only the current state; pruning at 10 block intervals
# custom: allow pruning options to be manually specified through 'pruning-keep-recent', 'pruning-keep-every', and 'pruning-interval'
pruning = "${PRUNING:-default}"
# These are applied if and only if the pruning strategy is custom.
pruning-keep-recent = "${PRUNING_KEEP_RECENT:-0}"
pruning-keep-every = "${PRUNING_KEEP_EVERY:-0}"
pruning-interval = "${PRUNING_INTERVAL:-0}"
# HaltHeight contains a non-zero block height at which a node will gracefully
# halt and shutdown that can be used to assist upgrades and testing.
#
# Note: Commitment of state will be attempted on the corresponding block.
halt-height = ${HALT_HEIGHT:-0}
# HaltTime contains a non-zero minimum block time (in Unix seconds) at which
# a node will gracefully halt and shutdown that can be used to assist upgrades
# and testing.
#
# Note: Commitment of state will be attempted on the corresponding block.
halt-time = ${HALT_TIME:-0}
# MinRetainBlocks defines the minimum block height offset from the current
# block being committed, such that all blocks past this offset are pruned
# from Tendermint. It is used as part of the process of determining the
# ResponseCommit.RetainHeight value during ABCI Commit. A value of 0 indicates
# that no blocks should be pruned.
#
# This configuration value is only responsible for pruning Tendermint blocks.
# It has no bearing on application state pruning which is determined by the
# "pruning-*" configurations.
#
# Note: Tendermint block pruning is dependant on this parameter in conunction
# with the unbonding (safety threshold) period, state pruning and state sync
# snapshot parameters to determine the correct minimum value of
# ResponseCommit.RetainHeight.
min-retain-blocks = 0
# InterBlockCache enables inter-block caching.
inter-block-cache = true
# IndexEvents defines the set of events in the form {eventType}.{attributeKey},
# which informs Tendermint what to index. If empty, all events will be indexed.
#
# Example:
# ["message.sender", "message.recipient"]
index-events = [${INDEX_TAGS:-}]
###############################################################################
###                         Telemetry Configuration                         ###
###############################################################################
[telemetry]
# Prefixed with keys to separate services.
service-name = ""
# Enabled enables the application telemetry functionality. When enabled,
# an in-memory sink is also enabled by default. Operators may also enabled
# other sinks such as Prometheus.
enabled = false
# Enable prefixing gauge values with hostname.
enable-hostname = false
# Enable adding hostname to labels.
enable-hostname-label = false
# Enable adding service to labels.
enable-service-label = false
# PrometheusRetentionTime, when positive, enables a Prometheus metrics sink.
prometheus-retention-time = 0
# GlobalLabels defines a global set of name/value label tuples applied to all
# metrics emitted using the wrapper functions defined in telemetry package.
#
# Example:
# [["chain_id", "cosmoshub-1"]]
global-labels = [
]
###############################################################################
###                           API Configuration                             ###
###############################################################################
[api]
# Enable defines if the API server should be enabled.
enable = ${API:-false}
# Swagger defines if swagger documentation should automatically be registered.
swagger = ${SWAGGER:-false}
# Address defines the API server to listen on.
address = "${API_LADDR:-tcp://0.0.0.0}:${API_PORT:-1317}"
# MaxOpenConnections defines the number of maximum open connections.
max-open-connections = 1000
# RPCReadTimeout defines the Tendermint RPC read timeout (in seconds).
rpc-read-timeout = 10
# RPCWriteTimeout defines the Tendermint RPC write timeout (in seconds).
rpc-write-timeout = 0
# RPCMaxBodyBytes defines the Tendermint maximum response body (in bytes).
rpc-max-body-bytes = 1000000
# EnableUnsafeCORS defines if CORS should be enabled (unsafe - use it at your own risk).
enabled-unsafe-cors = ${UNSAFE_CORS:-false}
###############################################################################
###                           gRPC Configuration                            ###
###############################################################################
[grpc]
# Enable defines if the gRPC server should be enabled.
enable = ${GRPC_ENABLE:-true}
# Address defines the gRPC server address to bind to.
address = "${GRPC_LADDR:-0.0.0.0:9090}"
###############################################################################
###                        State Sync Configuration                         ###
###############################################################################
# State sync snapshots allow other nodes to rapidly join the network without replaying historical
# blocks, instead downloading and applying a snapshot of the application state at a given height.
[state-sync]
# snapshot-interval specifies the block interval at which local state sync snapshots are
# taken (0 to disable). Must be a multiple of pruning-keep-every.
snapshot-interval = 0
# snapshot-keep-recent specifies the number of recent snapshots to keep and serve (0 to keep all).
snapshot-keep-recent = 2
EOF
}

compare_replace_config() {
	TARGET_FILE=$1
	TEMP_FILE=$2

	if [ ! -f "$TARGET_FILE" ]; then
		echo "no existing file found, creating.."
		mv "$TEMP_FILE" "$TARGET_FILE"
	else
		TARGET_FILE_HASH=$(sha256sum "$TARGET_FILE" | awk '{print $1}')
		TEMP_FILE_HASH=$(sha256sum "$TEMP_FILE" | awk '{print $1}')
		if [ "$TARGET_FILE_HASH" = "$TEMP_FILE_HASH" ]; then
			echo "$TARGET_FILE is up-to-date -- $TARGET_FILE_HASH"
			rm "$TEMP_FILE"
		else
			echo "changes detected, updating.."
			rm "$TARGET_FILE"
			mv "$TEMP_FILE" "$TARGET_FILE"
		fi
	fi

}



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

 	echo "Importing Account '$IMP_ACCOUNT_NAME'..."

    cronosd keys add $IMP_ACCOUNT_NAME --recover --keyring-backend $IMP_KEYRING < <(echo "$IMP_ACCOUNT_MNEMONIC")

    cronosd add-genesis-account $(cronosd keys show $IMP_ACCOUNT_NAME -a --keyring-backend $IMP_KEYRING) ${IMP_ACCOUNT_BALANCE:-1000000000000000000}${COIN:-cro} --keyring-backend $IMP_KEYRING

    echo "Finished Importing Account '$IMP_ACCOUNT_NAME' ..."	

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

	#output all required data to a CSV file
    echo -e "$ACCOUNT_NAME,`cat ~/account_account01.address`,$ACCOUNT_BALANCE,`cat ~/account_account01.privkey`,`cat ~/account_account01.mnemonic`\n"   >> ~/accounts.csv

    echo "Finished Generationg Account '$ACCOUNT_NAME' ..."
} #End of AddAccount


initialize() {
	NODE_DIR=$1
	BINARY=$2

	if [ $# != 2 ]; then
		echo "expected 4 arguments for initialize"
		exit 1
	fi

	if [ ! -f "$NODE_DIR/config/genesis.json" ]; then
		echo "no existing genesis file found, initializing.."

      # Create new set of cronos keys
      #[CT May22] dumping out the account nmemonic for use elsewhere
      $BINARY keys add $KEY --keyring-backend $KEYRING  > ~/account_mnemonic.txt 2>&1

      #[CT] TODO: IN PROD WE DONT WANT TO AUTO GEN OR OUTPUT KEYS
      cat ~/account_mnemonic.txt


		$BINARY init ${NODE_NAME:-nonamenode} --chain-id=${CHAIN_ID:-bbteam_1337-1}
		# Allocate genesis accounts (cosmos formatted addresses)

		#cronosd add-genesis-account $(cronosd keys show $KEY -a) 10000000000000stake,100000000000000000000000000basecro --keyring-backend $KEYRING
		$BINARY add-genesis-account $($BINARY keys show $KEY -a --keyring-backend $KEYRING) 100000000000000000000000000${COIN:-cro} --keyring-backend $KEYRING

		# Change parameter token denominations to basecro
		cat ~/.cronos/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="'${COIN:-cro}'"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
		cat ~/.cronos/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="'${COIN:-cro}'"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
		cat ~/.cronos/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="'${COIN:-cro}'"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
		cat ~/.cronos/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="'${COIN:-cro}'"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
		cat ~/.cronos/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="'${COIN:-cro}'"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
		cat ~/.cronos/config/genesis.json | jq '.app_state["inflation"]["params"]["mint_denom"]="'${COIN:-cro}'"' > ~/.cronos/config/tmp_genesis.json && mv ~/.cronos/config/tmp_genesis.json ~/.cronos/config/genesis.json
		
		if [ ! -f "~/accounts.csv" ]; then
			echo "no existing '~/accounts.csv' file found, initializing '$NUM_TEST_ACCOUNTS' accounts.."

			echo -e "Name,Public Address,Balance,Private Key,Mnemonic\n"   > ~/accounts.csv
			
			for (( accountNumber = 1; accountNumber <= $NUM_TEST_ACCOUNTS; accountNumber++ ))
			do  
				AddAccount "account$accountNumber" "$TEST_ACCOUNT_BAL" $KEYRING
			done  #  for (( accountNumber = 1; accountNumber <= $NUM_TEST_ACCOUNTS; accountNumber++ ))

			echo "#### ACCOUNTS GENERATED - PLEASE SEE ~/accounts.csv ####"
		else
			echo "FOUND '~/accounts.csv' file, importing accounts.."


			while IFS=, read -r accountName accountAddr accountBal accountPrvKey accountMnemonic
			do
				ImportExistingAccount "$accountName" "$accountMnemonic" $accountBal $KEYRING
			done < ~/accounts.csv


			echo "Accounts Imported!"
		fi # if [ -f "~/accounts.csv" ]; then

		# Sign genesis transaction
		$BINARY gentx $KEY 10000000000000000000${COIN:-cro} --keyring-backend $KEYRING --chain-id $CHAIN_ID 

		# Collect genesis tx
		$BINARY collect-gentxs

		# Run this to ensure everything worked and that the genesis file is setup correctly
		$BINARY validate-genesis
	fi
}

update_config_files() {
	CONFIG_DIR=$1
	TEMP_DIR="${CONFIG_DIR}/temp"

	mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"

	write_app_toml
	write_client_toml
	write_config_toml

	cd "$CONFIG_DIR"

	compare_replace_config "${CONFIG_DIR}/app.toml" "${TEMP_DIR}/app.toml"
	compare_replace_config "${CONFIG_DIR}/client.toml" "${TEMP_DIR}/client.toml"
	compare_replace_config "${CONFIG_DIR}/config.toml" "${TEMP_DIR}/config.toml"

	rm -rf "$TEMP_DIR"
}

initialize "${HOME:-/.cronosd}" cronosd
update_config_files "${HOME:-/.cronosd}/config"

#cronosd start --pruning=nothing $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0.0001basecro --json-rpc.api eth,txpool,personal,net,debug,web3
exec supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf
