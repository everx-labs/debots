#!/usr/bin/env bash

set -e

tos=tonos-cli

DEBOT_NAME=AccMan
DEBOT_CLIENT=deployerDebot
giver=0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94
function giver {
$tos --url $NETWORK call --abi ../local_giver.abi.json $giver sendGrams "{\"dest\":\"$1\",\"amount\":30000000000}"
}
function get_address {
echo $(cat log.log | grep "Raw address:" | cut -d ' ' -f 3)
}
function genaddr {
$tos genaddr $1.tvc $1.abi.json --genkey $1.keys.json > log.log
}
function deploy {
echo GENADDR $1 ----------------------------------------------
genaddr $1
DEBOT_ADDRESS=$(get_address)
echo GIVER $1 ------------------------------------------------
giver $DEBOT_ADDRESS
echo DEPLOY $1 -----------------------------------------------
$tos --url $NETWORK deploy $1.tvc "{}" --sign $1.keys.json --abi $1.abi.json
DEBOT_ABI=$(cat $1.abi.json | xxd -ps -c 20000)
$tos --url $NETWORK call $DEBOT_ADDRESS setABI "{\"dabi\":\"$DEBOT_ABI\"}" --sign $1.keys.json --abi $1.abi.json
echo -n $DEBOT_ADDRESS > $1.addr
}

function deployMsig {
msig=SafeMultisigWallet
echo GENADDR $msig ----------------------------------------------
genaddr $msig
ADDRESS=$(get_address)
echo GIVER $msig ------------------------------------------------
giver $ADDRESS
echo DEPLOY $msig -----------------------------------------------
PUBLIC_KEY=$(cat $msig.keys.json | jq .public)
$tos --url $NETWORK deploy $msig.tvc "{\"owners\":[\"0x${PUBLIC_KEY:1:64}\"],\"reqConfirms\":1}" --sign $msig.keys.json --abi $msig.abi.json
echo -n $ADDRESS > msig.addr
mv $msig.keys.json msig.key
}

LOCALNET=http://127.0.0.1
DEVNET=https://net.ton.dev
MAINNET=https://main.ton.dev
NETWORK=$LOCALNET

deployMsig
MSIG_ADDRESS=$(cat msig.addr)

deploy $DEBOT_NAME
DEBOT_ADDRESS=$(cat $DEBOT_NAME.addr)
ACCMAN_ADDRESS=$DEBOT_ADDRESS

#ICON_BYTES=$(base64 -w 0 hellodebot.png)
#ICON=$(echo -n "data:image/png;base64,$ICON_BYTES" | xxd -ps -c 20000)
IMAGE=$(base64 -w 0 AccBase.tvc)
$tos --url $NETWORK call $DEBOT_ADDRESS setAccountBase "{\"image\":\"$IMAGE\"}" --sign $DEBOT_NAME.keys.json --abi $DEBOT_NAME.abi.json
IMAGE=$(base64 -w 0 Invite.tvc)
$tos --url $NETWORK call $DEBOT_ADDRESS setInvite "{\"image\":\"$IMAGE\"}" --sign $DEBOT_NAME.keys.json --abi $DEBOT_NAME.abi.json
IMAGE=$(base64 -w 0 InviteRoot.tvc)
$tos --url $NETWORK call $DEBOT_ADDRESS setInviteRoot "{\"image\":\"$IMAGE\"}" --sign $DEBOT_NAME.keys.json --abi $DEBOT_NAME.abi.json
#$tos --url $NETWORK call $DEBOT_ADDRESS setIcon "{\"icon\":\"$ICON\"}" --sign $DEBOT_NAME.keys.json --abi $DEBOT_NAME.abi.json

echo DONE ------------------------------------------------------------------
echo debot $DEBOT_ADDRESS

deploy $DEBOT_CLIENT
DEBOT_ADDRESS=$(cat $DEBOT_CLIENT.addr)
$tos --url $NETWORK call $DEBOT_ADDRESS setAccman "{\"addr\":\"$ACCMAN_ADDRESS\"}" --sign $DEBOT_CLIENT.keys.json --abi $DEBOT_CLIENT.abi.json
IMAGE=$(base64 -w 0 Account.tvc)
$tos --url $NETWORK call $DEBOT_ADDRESS setAccount "{\"image\":\"$IMAGE\"}" --sign $DEBOT_CLIENT.keys.json --abi $DEBOT_CLIENT.abi.json
echo client $DEBOT_ADDRESS
echo debot $ACCMAN_ADDRESS
echo msig $MSIG_ADDRESS

$tos --url $NETWORK debot fetch $DEBOT_ADDRESS
