#params
[bool] $test = 1
$projectId="test001"
$timeToMint = 3200 # 1 hour

if($test){
    $network="--testnet-magic", "1097911063"
    $addr="addr_test1xxxxxxxxxxxxxxxxxxxxxx"
    $logfile="C:\Users\user\AppData\Roaming\Daedalus Testnet\Logs\pub\cardano-wallet.log"
} else {
    $network="--mainnet"
    $addr="addr1xxxxxxxxxxxxxxxxxxxxxx"
    $logfile="C:\Users\user\AppData\Roaming\Daedalus Mainnet\Logs\pub\cardano-wallet.log"
}

#init
cd C:\Users\user\Documents\cardano

Select-String '^.*--node-socket (\S+).*$' $logfile | 
  Select-Object -Last 1 |
    ForEach-Object { $socket = $_.Matches[0].Groups[1].Value } #get last occurence in file
$env:CARDANO_NODE_SOCKET_PATH = $socket

$policyId= Get-Content policy\policyid.txt -TotalCount 1

#fetch metadata
$data = Get-Content ipfs\nft_config.json -Raw | ConvertFrom-Json
$mint = ""
for ($i=0; $i -lt $data.length; $i++){
    $mint +="`"$($data[$i].amount) $($policyId).$($data[$i].id)`""+(&{if($i -lt $data.length-1) {"+"} else {""}})
}

cd mint

Write-Host("network  : "+$network)
Write-Host("logfile  : "+$logfile)
Write-Host("socket   : "+$socket)
Write-Host("policyid : "+$policyId)
Write-Host("mint     : "+$mint)

#process
$tip = cardano-cli query tip $network
$slot = ($tip | Out-String | ConvertFrom-Json).slot

cardano-cli query protocol-parameters $network --out-file protocol.json
$balance = cardano-cli query utxo --address $addr $network
$balance > balance.txt
$balance = $balance[2..($balance.Length-1)] # remove header and separator

$tx      = $balance -replace '^(\S+)\s+(\d+)\s+(\d+) lovelace.*$', '$1#$2'
$amounts = $balance -replace '^(\S+)\s+(\d+)\s+(\d+) lovelace.*$', '$3'
$premint = $balance -replace '^(\S+)\s+(\d+)\s+(\d+) lovelace(( \+ \d+ [a-f0-9]{56}\.\S+)*) \+ TxOutDatumHashNone$', '$4"'
$premint = $premint -replace ' \+ ', '"+"'
$premint = $premint.substring(2)
Write-Host("premint  : "+$premint)

$txin  = $tx[0]
$txout = "$($addr)+$($amounts[0])+$($premint)+$($mint)"

cardano-cli transaction build-raw `
  --fee 0 `
  --tx-in $txin `
  --tx-out $txout `
  --mint=$mint `
  --minting-script-file ../policy/policy.script `
  --metadata-json-file ../ipfs/nft_meta.json `
  --invalid-hereafter=29541804 `
  --out-file matx.raw

#get fee
$fee = cardano-cli transaction calculate-min-fee `
  --tx-body-file matx.raw `
  --tx-in-count 1 `
  --tx-out-count 1 `
  --witness-count 2 `
  --mainnet `
  --protocol-params-file protocol.json
$fee = $fee -replace '^(\d+) Lovelace$', '$1'

$txout = "$($addr)+$($amounts[0]-$fee)+$($premint)+$($mint)"

Write-Host("txin     : $($txin)")
Write-Host("txout    : $($txout)")
Write-Host("amount   : $($amounts[0]) - $($fee) = $($amounts[0]-$fee)")

#Write-Host($slot+$timeToMint) # 2do before
$before = 41480089

cardano-cli transaction build-raw `
  --fee $fee `
  --tx-in $txin `
  --tx-out $txout `
  --mint="$mint" `
  --minting-script-file ../policy/policy.script `
  --metadata-json-file ../ipfs/nft_meta.json `
  --invalid-hereafter=$before `
  --out-file matx.raw

cardano-cli transaction sign `
  --signing-key-file ../payskey/tn.payment-0.skey `
  --signing-key-file ../payskey/tn.stake.skey `
  --signing-key-file ../policy/policy.skey `
  $network `
  --tx-body-file matx.raw `
  --out-file matx.signed

cardano-cli transaction submit --tx-file matx.signed $network