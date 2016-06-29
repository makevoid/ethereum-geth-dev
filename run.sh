docker build -t='ethereum/geth' . && \

docker run -p 8545:8545 -v datadir:/datadir ethereum/geth

# named datadir - good interop with other containers, they can all connect via /datadir/geth.ipc
#
#
# additional notes:
#
#
# You will end up with geth.ipc being created here (on linux):
#
#   /var/lib/docker/volumes/datadir/_data
#
