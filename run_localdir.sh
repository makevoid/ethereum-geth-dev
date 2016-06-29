sudo rm -f $PWD/datadir/geth.ipc && \

docker build -t='ethereum/geth' . && \

docker run -p 8545:8545 -v $PWD/datadir:/datadir ethereum/geth

# this uses local datadir (unfortunately it doesn't get shared well with other containers)
