sudo rm -f $PWD/datadir/geth.ipc && \

docker build -t='ethereum/geth' . && \

docker run -p 8545:8545 -v $PWD/datadir:/datadir ethereum/geth
# docker run -p 8545:8545 -v datadir:/datadir ethereum/geth  # --- named datadir
