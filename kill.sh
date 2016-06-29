docker kill $(docker ps -a -q  --filter ancestor=ethereum/geth --filter status=running)
