$blockfrostApiKey="xxxxxxxxxxxxxxxxxxxxxx"
$curlExe = 'C:\Program Files\xxxxxxxxxxxx\mingw64\bin\curl.exe'
$data = @(
    [pscustomobject]@{file='test1.png';id='test1';name='Test #1';amount=1}
    [pscustomobject]@{file='test2.png';id='test2';name='Test #2';amount=1}
)

#init
cd C:\Users\user\Documents\cardano\ipfs
$policyId= Get-Content ..\policy\policyid.txt -TotalCount 1
$data | ConvertTo-Json | Out-File "nft_config.json"

#create file
"{
  `"721`": {
    `"$policyId`": {" | Out-File -FilePath nft_meta.json
for ($i=0; $i -lt $data.length; $i++){
    $hash = $(& $curlExe 'https://ipfs.blockfrost.io/api/v0/ipfs/add',
                             '-X', 'POST',
                             '-H', "project_id: $blockfrostApiKey",
                             '-F', "file=@$($data[$i].file)"| Out-String | ConvertFrom-Json).ipfs_hash
"      `"$($data[$i].id)`": {
        `"name`": `"$($data[$i].name)`",
        `"image`": `"ipfs://$hash`"
      }"+(&{if($i -lt $data.length-1) {","} else {""}}) >> nft_meta.json
}
"    }
  }
}" >> nft_meta.json
[string]::Join( "`n", (gc nft_meta.json)) | sc nft_meta.json