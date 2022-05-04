
#https://raw.githubusercontent.com/prelegalwonder/Docker-poa-blockscout/master/docker/entrypoint.sh
#!/bin/bash

export HOME=/home/scoutusr
export MIX_ENV=prod

if [ ! -v CHAIN_NAME ]
  then
    export CHAIN_NAME='sokol'
fi

if [ ! -v DB_NAME ]
  then
    export DB_NAME=${CHAIN_NAME}
fi

if [ ! -v DB_HOST ]
  then
    export DB_HOST='postgresql'
fi

if [ ! -v DB_PORT ]
  then
    export DB_PORT=5432
fi

if [ ! -v DB_USER ]
  then
    #export DB_USER='poadbusr'
    export DB_USER='postgres'
fi

if [ ! -v DB_PASS ]
  then
    export DB_PASS='1234qwer'
fi

if [ ! -v DATABASE_URL ]
  then
    export DATABASE_URL="postgresql://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT"
fi

if [ ! -v PORT ]
  then
    export PORT=4000
fi

/opt/app/bin/deployment/migrate 

if [ $? -eq 0 ]
  then
  #/opt/blockscout/bin/deployment/start
  source /etc/environment
  
  echo "Starting Blockscout.."
  
  mix phx.server
else
  echo "Migration failed, see output."
fi
