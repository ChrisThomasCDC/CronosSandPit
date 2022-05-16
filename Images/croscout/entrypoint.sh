
#https://raw.githubusercontent.com/prelegalwonder/Docker-poa-blockscout/master/docker/entrypoint.sh
#!/bin/bash

#export HOME=/home/scoutusr
export MIX_ENV=prod
export DISABLE_EXCHANGE_RATES=true
export DISABLE_KNOWN_TOKENS=true

if [ ! -v CHAIN_NAME ]
  then
    export CHAIN_NAME='CRONOS'
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


echo $(pwd)

set -e

#echo "waiting 4 seconds for DB..."
#sleep 4

# echo "verifying database availability..."


# bash-5.0# nc -vzw1 172.17.0.1 5432
# 172.17.0.1 (172.17.0.1:5432) open

#until PGPASSWORD=$DB_PASS psql -h "$DB_USER" -U "$DB_HOST" -c '\q'; do
#  >&2 echo "Postgres is unavailable - sleeping"
#  sleep 1
#
#done


# nc -vzw1 172.17.0.2 5432


# mix ecto.drop
mix ecto.drop

echo "Creating DB...."
mix ecto.create
echo "DB created!"
echo "Creating Tables...."
mix ecto.migrate
echo "Tables created!"

echo "Starting Server...."
mix phx.server