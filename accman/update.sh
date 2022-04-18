#!/bin/bash
set -ex
filename=AccMan
filenamesol=$filename.sol
filenameabi=$filename.abi.json
filenametvc=$filename.tvc
filenamekeys=$filename.keys.json

export tos=tonos-cli
export NETWORK=${1:-localhost}

function toscall {
$tos --url $NETWORK call $debot_address $1 $2 --sign $filenamekeys --abi $filenameabi > /dev/null
}

if [ "${UPDATE:-false}" == "false" ]; then
    echo 1. Deploy DeBot and set ABI
    bash ../../deploy_debot.sh $filename > /dev/null
    debot_address=$(cat $filename.addr)
else
    debot_address=$(cat $filename.addr)
    echo 1. Update DeBot and set ABI
    toscall upgrade "{\"state\":\"$(base64 -w 0 $filename.tvc)\"}"
    toscall setABI "{\"dabi\":\"$(cat $filename.abi.json | xxd -ps -c 20000)\"}"
fi

echo 2. Set AccountBase
IMAGE=$(base64 -w 0 AccBase.tvc)
$tos --url $NETWORK call $debot_address setAccountBase "{\"image\":\"$IMAGE\"}" --sign $filenamekeys --abi $filenameabi
echo 3. Set Invite
IMAGE=$(base64 -w 0 Invite.tvc)
$tos --url $NETWORK call $debot_address setInvite "{\"image\":\"$IMAGE\"}" --sign $filenamekeys --abi $filenameabi
echo 4. Set InviteRoot
IMAGE=$(base64 -w 0 InviteRoot.tvc)
$tos --url $NETWORK call $debot_address setInviteRoot "{\"image\":\"$IMAGE\"}" --sign $filenamekeys --abi $filenameabi

echo DONE
if [ "${UPDATE:-false}" == "false" ]; then
    echo -n $debot_address > $filename.addr
fi

