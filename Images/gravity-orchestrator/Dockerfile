#https://github.com/crypto-org-chain/gravity-bridge/blob/cronos/orchestrator/Dockerfile
# docker build --no-cache --build-arg REPO_VERSION=v2.0.0-cronos -t bb-team/gorc .
# docker run --name rust -it --entrypoint bash bb-team/gorc

FROM rust:slim-bullseye as cargo-chef-rust
# Specify Which Version We Want
ARG REPO_VERSION=v2.0.0-cronos

# Make Sure We Have An Updated Container
RUN apt update && apt -y upgrade && apt -y install git libssl-dev pkg-config libudev-dev perl make && cargo install cargo-chef

WORKDIR /app
RUN git clone https://github.com/crypto-org-chain/gravity-bridge.git .  \
   && git checkout ${NODE_VERSION}

FROM cargo-chef-rust as planner
WORKDIR /app/orchestrator
# We only pay the installation cost once,
# it will be cached from the second build onwards
# To ensure a reproducible build consider pinning
# the cargo-chef version with `--version X.X.X`
RUN cargo chef prepare --recipe-path recipe.json


FROM cargo-chef-rust as cacher
WORKDIR /app/orchestrator
COPY --from=planner /app/orchestrator/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

FROM cargo-chef-rust as builder
WORKDIR /app/orchestrator

# Copy over the cached dependencies
COPY --from=cacher /app/orchestrator/target target
COPY --from=cacher /usr/local/cargo /usr/local/cargo
RUN cargo build --release --bin orchestrator

FROM cargo-chef-rust as runtime
WORKDIR /app
COPY --from=builder /app/orchestrator/target/release/orchestrator /usr/local/bin
CMD orchestratorexit

#$ orchestrator --cosmos-phrase="{mnemonic_phrase_of_cronos_acount}" \
#    --ethereum-key={private_key_of_ethereum_account} \
#    --cosmos-grpc=http://localhost:{cronos_grpc_port} \
#    --ethereum-rpc={ethereum_web3_endpoint} \
#    --address-prefix=crc --fees=basetcro \
#    --contract-address={gravity_contract_address} \
#    --metrics-listen 127.0.0.1:3000 --hd-wallet-path="m/44'/60'/0'/0/0"