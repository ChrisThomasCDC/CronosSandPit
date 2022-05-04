#!/bin/bash

docker-compose -f docker-compose.yml down


echo "Nuking croval01 Data.."
rm -rf localnet-setup/croval01/.*

echo "Nuking croscout01 Data.."
rm -rf localnet-setup/croscout01/.*

docker-compose -f docker-compose.yml up -d


