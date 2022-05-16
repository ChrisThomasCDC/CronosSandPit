
#https://github.com/RyanHendricks/Docker-Ethereum-Testnet/blob/master/scripts/dockerlint.sh

#!/bin/bash
docker rm -f $(docker ps -a -q)
wait 3
docker rmi $(docker images -q)
wait 3
docker volume prune -f
wait 3
docker network prune -f