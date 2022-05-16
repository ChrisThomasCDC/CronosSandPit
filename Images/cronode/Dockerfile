

# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       
# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE   
# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE   
# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE   
# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE   
# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE   


# Reference Material (Prior Works)
#  https://github.com/cosmos/ethermint/blob/development/networks/local/ethermintnode/Dockerfile
#  https://github.com/cosmos/ethermint/blob/development/scripts/start.sh
#  https://github.com/tharsis/evmos/blob/main/init.sh
#  https://docs.tendermint.com/master/tools/docker-compose.html


# Example Useage:

#docker run --rm -it --entrypoint bash bb-team/cronode

#docker run --name croval01 -it --entrypoint bash -v $(pwd)/debug.environment.cronode:/etc/environment:ro bb-team/cronode

#docker run --name croval01 -v $(pwd)/debug.environment.cronode:/etc/environment:ro -d bb-team/cronode

#   docker run --name croval01 -e LOGLEVEL=info -v $(pwd)/Images/cronode/supervisor/conf.d/supervisord.cronode.conf:/etc/supervisor/conf.d/supervisord.cronode.conf:ro -v $(pwd)/debug.environment.cronode:/etc/environment:ro -d bb-team/cronode




#docker build --no-cache --build-arg NODE_VERSION=release/v0.7.x -t bb-team/cronode .

FROM golang:bullseye AS build-env

WORKDIR /go/src/github.com/crypto-org-chain

# Install minimum necessary dependencies
ENV PACKAGES curl make git libc-dev bash gcc

ARG NODE_VERSION=release/v0.7.x


RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y $PACKAGES

RUN git clone https://github.com/crypto-org-chain/cronos.git cronos \
   && cd cronos \
   && git checkout ${NODE_VERSION} \
   && make build

#RUN cd cronos && make build -o cronosd


FROM golang:bullseye

# to trace evm
#TRACE="--trace"
ENV TRACE=""
ENV LOGLEVEL=info

# Prod Deps
RUN apt update && apt-get upgrade -y && apt install ca-certificates jq bc supervisor -y

#Dev/Test Tools
RUN apt install net-tools -y

# Create Application User 
RUN groupadd -r nodeusr \
    && useradd -r -m -d /home/nodeusr -g nodeusr nodeusr 

COPY ./start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh

# Set working dir and App user
WORKDIR /home/nodeusr
USER nodeusr

COPY --from=build-env /go/src/github.com/crypto-org-chain/cronos/build/cronosd /usr/bin/cronosd

# Add supervisor configuration files
RUN mkdir -p /etc/supervisor/conf.d/
COPY ./supervisor/supervisord.conf /etc/supervisor/supervisord.conf 
COPY ./supervisor/conf.d/* /etc/supervisor/conf.d/

# Tendermint -  P2P
EXPOSE 26656 

# Tendermint - RPC
EXPOSE 26657

# Tendermint -  API
EXPOSE 1317

#Tendermint -  gRPC
EXPOSE 9090 

#Tendermint - PProf Profiling
EXPOSE 6060

#CRONOS - JSON-RPC
EXPOSE 8545

#CRONOS - WS
EXPOSE 8546

ENTRYPOINT ["/usr/bin/start.sh"]

#cronosd start --address "tcp://localhost:8545" --pruning=nothing --log_level info --minimum-gas-prices=0.0001basecro --rpc.unsafe

