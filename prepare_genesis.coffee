# Web3 = require "web3"
# fs   = require 'fs'
#
# host = "http://localhost:8545"
# web3 = new Web3(new Web3.providers.HttpProvider host)
# eth  = web3.eth

coinbase = eth.coinbase

genesisPath ='./config/genesis.json'
genesis = fs.readFileSync genesisPath
genesis.replace "ADDRESS", coinbase
fs.writeFileSync genesisPath, genesis

console.log "-----------------------------"
console.log "Balance:"
console.log "-----------------------------"
console.log eth.getBalance(eth.coinbase)
console.log "-----------------------------"

process.exit 0
