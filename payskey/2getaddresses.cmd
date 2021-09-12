rem 5. Generate the addresses by computing the payment key and the stake key
cardano-cli address build --testnet-magic 1097911063 --payment-verification-key addr_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --stake-verification-key stake_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --out-file tn.payment-0.address
rem                                                                             ^ tn.payment-0.pub                                                                          ^ tn.stake.pub
rem If you cat this address tn.payment-0.address it should match your address in your wallet.

rem Now you can generate your payment using:
rem Source payment address: tn.payment-0.address
rem Source payment signing key: tn.payment-0.skey
pause