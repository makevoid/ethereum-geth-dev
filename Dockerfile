FROM ubuntu:xenial

# --------------------
# nodejs
#
RUN apt-get update
RUN apt-get install -y curl rlwrap

RUN curl https://deb.nodesource.com/node_6.x/pool/main/n/nodejs/nodejs_6.2.0-1nodesource1~trusty1_amd64.deb > node.deb \
 && dpkg -i node.deb \
 && rm node.deb

RUN npm install -g pangyp\
 && ln -s $(which pangyp) $(dirname $(which pangyp))/node-gyp\
 && npm cache clear\
 && node-gyp configure || echo ""

ENV NODE_ENV production
#
# / nodejs
# --------------------

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -q -y && \
    apt-get dist-upgrade -q -y && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 923F6CA9 && \
    echo "deb http://ppa.launchpad.net/ethereum/ethereum/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/ethereum.list && \
    apt-get update && \
    apt-get install -q -y geth && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update

RUN apt-get install -y git
RUN npm i -g coffee-script

WORKDIR /app

ADD package.json /app
ADD package.json /tmp/package.json
RUN npm i

ADD config /app/config
# RUN ls (add/change this line if you want to regenerate a naw address)

RUN geth --datadir . --password config/password.txt account new
# RUN geth account list (for verification)

ADD coffeeify /app
ADD prepare_genesis /app

ADD *.coffee /app
ADD lib /app
RUN ./coffeeify

RUN ./prepare_genesis
RUN geth  --datadir . --dev init config/genesis.json
RUN cat ./config/genesis.json

# this line will check if your account has the ethers specified into genesis.json>alloc
# RUN geth --datadir . --dev --exec "eth.getBalance(eth.coinbase)" console

# "--ipcpath", "/datadir/geth.ipc", 
# VOLUME /datadir

EXPOSE 8545
EXPOSE 30303
# TODO - check: port 30303 needed?

ENTRYPOINT ["/usr/bin/geth",  "--datadir", ".", "--password", "config/password.txt", "--unlock", "0", "--dev", "--rpc", "--rpcaddr", "0.0.0.0", "js", "./dist/geth_mine.js"]
