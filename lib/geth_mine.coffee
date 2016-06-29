# geth_mine.coffee - activate mining to mine pending transactions - forked by embark-framework
#

# library (from underscore)

now = Date.now or ->
  (new Date).getTime()

debounce = (func, wait) ->
  timeout = undefined
  args = undefined
  context = undefined
  timestamp = undefined
  result = undefined

  later = ->
    last = now() - timestamp
    if last < wait and last >= 0
      timeout = setTimeout(later, wait - last)
    else
      timeout = null
      result = func.apply(context, args)
      if !timeout
        context = args = null
    return

  ->
    context = this
    args = arguments
    timestamp = now()
    if !timeout
      timeout = setTimeout(later, wait)
    result

# code

eth = web3.eth

do ->
  console.log 'geth_mine.js: start'
  console.log "node infos: #{JSON.stringify admin.nodeInfo}"

  config =
    threads: 8

  old_geth = admin.nodeInfo.name.match /^Geth\/v1\.3/

  miner_stop = ->
    if old_geth
      miner.stop config.threads
    else
      miner.stop()

  miner_start = ->
    if old_geth
      miner.start config.threads
    else
      miner.start()

  main = ->
    miner_stop()

    startTransactionMining()

  pendingTransactions = ->
    if !eth.pendingTransactions
      txpool.status.pending or txpool.status.queued
    else if typeof eth.pendingTransactions == 'function'
      eth.pendingTransactions().length > 0
    else
      eth.pendingTransactions.length > 0 || eth.getBlock('pending').transactions.length > 0

  ifNoPendingTransactions = (callback) ->
    if !pendingTransactions()
      callback()


  stillMining = (callback) ->
    miner.hashrate > 0

  ifNotMiningDo = (callbackWhenInactive) ->
    if !stillMining()
      callbackWhenInactive()

  ifNoPendingTransactionsDeb = debounce ifNoPendingTransactions, 200
  ifNotMiningDoDeb           = debounce ifNotMiningDo, 200

  startTransactionMining = ->
    eth.filter('pending').watch ->
      ifNotMiningDoDeb ->
        console.log '== Pending transactions! Looking for next block...'
        miner.start config.threads

    eth.filter('latest').watch ->
      ifNoPendingTransactionsDeb ->
        console.log '== No transactions left. Stopping miner...'
        miner.stop()

  main()
