
#!/bin/bash
set -e

tos=./tonos-cli
if test -f "$tos"; then
    echo "$tos exists."
else
    echo "$tos not found in current directory. Please, copy it here and rerun script."
    exit
fi

DEBOT_NAME=helloDebot
giver=0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94
function giver {
./tonos-cli call --abi ~/local_giver.abi.json $giver sendGrams "{\"dest\":\"$1\",\"amount\":10000000000}"
}
function get_address {
echo $(cat log.log | grep "Raw address:" | cut -d ' ' -f 3)
}
function genaddr {
./tonos-cli genaddr $1.tvc $1.abi.json --genkey $1.keys.json > log.log
}

echo GENADDR DEBOT
genaddr $DEBOT_NAME
DEBOT_ADDRESS=$(get_address)
echo DEPLOY DEBOT $DEBOT_ADDRESS
giver $DEBOT_ADDRESS
debot_abi=$(cat $DEBOT_NAME.abi.json | xxd -ps -c 20000)

./tonos-cli deploy $DEBOT_NAME.tvc "{}" --sign $DEBOT_NAME.keys.json --abi $DEBOT_NAME.abi.json
./tonos-cli call $DEBOT_ADDRESS setABI "{\"dabi\":\"$debot_abi\"}" --sign $DEBOT_NAME.keys.json --abi $DEBOT_NAME.abi.json

echo DONE
echo $DEBOT_ADDRESS > address.log
echo debot  $DEBOT_ADDRESS

./tonos-cli debot fetch $DEBOT_ADDRESS