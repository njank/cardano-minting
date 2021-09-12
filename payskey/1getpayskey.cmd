echo average puppy recipe ... party | cardano-address key from-recovery-phrase Shelley > tn.root.prv
cardano-wallet key child 1852H/1815H/0H/1/1 < tn.root.prv > tn.payment-0.prv
cardano-wallet key public --without-chain-code < tn.payment-0.prv > tn.payment-0.pub
cardano-cli key convert-cardano-address-key --shelley-payment-key --signing-key-file tn.payment-0.prv --out-file tn.payment-0.skey
cardano-wallet key child 1852H/1815H/0H/2/0    < tn.root.prv  > tn.stake.prv
cardano-wallet key public --without-chain-code < tn.stake.prv > tn.stake.pub
cardano-cli key convert-cardano-address-key --shelley-payment-key --signing-key-file tn.stake.prv --out-file tn.stake.skey
cardano-cli key verification-key --signing-key-file tn.stake.skey --verification-key-file tn.stake.vkey

pause