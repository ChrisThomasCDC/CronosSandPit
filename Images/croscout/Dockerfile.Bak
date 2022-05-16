

# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       
# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE   
# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE   
# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE   
# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE   
# NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE       NOT FOR PRODUCTION USE   




# Reference Material (Prior Works)
#   https://github.com/SurfingNerd/blockscout-docker-compose/blob/main/Dockerfile
#   https://github.com/prelegalwonder/Docker-poa-blockscout/blob/master/docker/Dockerfile

# This is a ubuntu minimal base because i want to install tools as its for a devnet and pwnage purpose

# Example usage
#docker run --rm -it --entrypoint bash bb-team/croscout
#docker build --no-cache --build-arg BLOCKSCOUT_VERSION=master -t bb-team/croscout .


# Manual Standup (Without Compose)
# the following steps will walk you through spinning up all dependant services ready to run blockscout.


# Run DB
        #docker run --name scoutdb -e POSTGRES_PASSWORD=Password123 -d postgres
        #sudo docker inspect scoutdb | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress'

        #if the IP is not 'scoutdb' then replace below with whatever is there

        # sed -i "s/scoutdb/IP/g" ./debug.environment.croscout


# Run Validator
    # Point it to any CRO node if you wish, the below builds a fresh testnet for you.
    
    #docker run --name croval01 -v $(PWD)/debug.environment.cronode:/etc/environment:ro -d bb-team/cronode
    #sudo docker inspect croval01 | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress'

    #if the IP is not 'croval01' then replace below with whatever is there

    # sed -i "s/croval01/IP/g" ./debug.environment.croscout

# Run Blockscout

    # Run Bash Shell, Pre-Init
        #docker run --name scout01 -v $(PWD)/debug.environment.croscout:/etc/environment:ro --rm -it --entrypoint bash bb-team/croscout

    # Run Normally
        #docker run --name scout01 -v $(PWD)/debug.environment.croscout:/etc/environment:ro --rm -it bb-team/croscout


# Cleanup
    #docker stop scoutdb && docker rm scoutdb
    #docker stop scout01 && docker rm scout01
    #docker stop croval01 && docker rm croval01



FROM elixir

ARG BLOCKSCOUT_VERSION=master
ENV DEBIAN_FRONTEND=noninteractive
ENV MIX_ENV=test
ENV BLOCKSCOUT_DNS=blockscout
ENV BLOCKSCOUT_FQDN=bbteam.local
ENV DATABASE_URL: "postgresql://postgresuser:password@postgressdb:5432/blockscout:ssl=false"


#https://docs.blockscout.com/for-developers/information-and-settings/client-settings-parity-geth-ganache
ENV ETHEREUM_JSONRPC_VARIANT=parity
ENV ETHEREUM_JSONRPC_HTTP_URL=http://localhost:8545
ENV ETHEREUM_JSONRPC_TRACE_URL=http://localhost:8545
ENV ETHEREUM_JSONRPC_WS_URL=http://localhost:8546

EXPOSE 4000

# Update Pkg-list and get build-reqs
RUN    apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get update \
    && apt-get install -yqq netcat curl gcc g++ make libtool automake supervisor locales jq cargo \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \ 
    && apt-get update \
    && apt install -yqq nodejs \
    && npm install -g brunch

# Create Application User 
RUN    mkdir -p /opt/app \
    && groupadd -r scoutusr \
    && useradd -r -m -d /home/scoutusr -g scoutusr scoutusr \
    && chown -R scoutusr: /opt/app


# Set working dir and App user
WORKDIR /opt/app
USER scoutusr

# Get Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y 

ENV PATH="$HOME/.cargo/bin:${PATH}"
ENV RUSTFLAGS="-C target-feature=-crt-static"

# Checkout defined version of blockscout to app dir
# and switch some hardcoded user info
RUN   git clone https://github.com/crypto-org-chain/cronos-blockscout.git /opt/app \
   && git checkout ${BLOCKSCOUT_VERSION} \
   && grep -Ri ec2-user * | cut -f1 -d: | xargs -i{} sed -i 's/ec2-user/scoutusr/g' {}


#########
#########
# BaseDocker is a repeatable image up to this point
# docker build --no-cache --build-arg BLOCKSCOUT_VERSION=master -t bb-team/croscoutbase -f BaseDocker .   

# Install Node.js and Elixir dependencies
# [CT Apr-22]  added package auto updates
RUN   cd apps/block_scout_web/assets && npm update --no-save && npm install; cd - \
   && cd apps/explorer && npm update --no-save && npm install; cd - 


# Install hex for updates
# Install rebar for installing
# update rustler package or keccak wont compile   
RUN mix local.hex --force && mix local.rebar --force && mix deps.get && mix deps.update rustler


#########
#########
# BaseDocker is a repeatable image up to this point
# docker build --no-cache --build-arg BLOCKSCOUT_VERSION=master -t bb-team/croscoutbase -f BaseDocker .   



# package is too old on hex so pull it down and compile

RUN rm -rf deps/ex_keccak \
    && git clone https://github.com/ayrat555/ex_keccak /opt/app/deps/ex_keccak \
    && cd deps/ex_keccak/ \
    && mix do deps.get compile; cd - && mix deps.update ex_keccak

RUN mix do deps.compile, compile  \
    && mkdir -p /opt/app/_build/prod/lib/explorer_web/priv/static/ \
    && mix phx.digest

RUN cd apps/explorer && npm install && cd - && chown -R scoutusr:scoutusr /opt/app

# Enable HTTPS in development. The Phoenix server only runs with HTTPS.
RUN cd apps/block_scout_web; mix phx.gen.cert ${BLOCKSCOUT_DNS} ${BLOCKSCOUT_FQDN}; cd -


# Switch back to root for system config tasks
USER root

# Copy in Process Management Config
COPY supervisord.conf /etc/supervisor/conf.d/
COPY entrypoint.sh /opt/app/entrypoint.sh
RUN chmod +x /opt/app/entrypoint.sh
# Set CMD Process
CMD ["/opt/app/entrypoint.sh"]