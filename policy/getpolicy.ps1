#params
[bool] $test = 1
$timeToMint = 3200 # 1 hour

if($test){
    $network="--testnet-magic", "1097911063"
    $addr="addr_test1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $logfile="C:\Users\user\AppData\Roaming\Daedalus Testnet\Logs\pub\cardano-wallet.log"
} else {
    $network="--mainnet"
    $addr="addr1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $logfile="C:\Users\user\AppData\Roaming\Daedalus Mainnet\Logs\pub\cardano-wallet.log"
}

#init
cd C:\Users\user\Documents\cardano

Select-String '^.*--node-socket (\S+).*$' $logfile | 
  Select-Object -Last 1 |
    ForEach-Object { $socket = $_.Matches[0].Groups[1].Value } #get last occurence in file
$env:CARDANO_NODE_SOCKET_PATH = $socket

cd policy

cardano-cli address key-gen --verification-key-file policy.vkey --signing-key-file policy.skey
$hash = cardano-cli address key-hash --payment-verification-key-file policy.vkey


"{
  `"type`": `"all`",
  `"scripts`": [
    {
      `"keyHash`": `"$hash`",
      `"type`": `"sig`"
    },
    {
      `"type`": `"before`",
      `"slot`": $before
    }
  ]
}" | Out-File -FilePath policy.script
[string]::Join( "`n", (gc policy.script)) | sc policy.script

$tip = cardano-cli query tip $network
$slot = ($tip | Out-String | ConvertFrom-Json).slot
$before = 41480089
$policyId = cardano-cli transaction policyid --script-file policy.script

Write-Host($policyId > policyid.txt)