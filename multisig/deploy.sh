
#!/bin/bash
set -e

tos=./tonos-cli
if test -f "$tos"; then
    echo "$tos exists."
else
    echo "$tos not found in current directory. Please, copy it here and rerun script."
    exit
fi

debot_name=msigDebotv1
#giver=0:2bb4a0e8391e7ea8877f4825064924bd41ce110fce97e939d3323999e1efbb13
giver=0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94
function giver {
#./tonos-cli call --abi ~/giverv2.abi.json --sign ~/giver.keys.json $giver sendTransaction "{\"dest\":\"$1\",\"value\":2000000000,\"bounce\":false}"
./tonos-cli call --abi ~/local_giver.abi.json $giver sendGrams "{\"dest\":\"$1\",\"amount\":10000000000}"
}
function get_address {
echo $(cat log.log | grep "Raw address:" | cut -d ' ' -f 3)
}
function genaddr {
./tonos-cli genaddr $1.tvc $1.abi.json --genkey $1.keys.json > log.log
}
./tonos-cli config --url http://0.0.0.0

echo GENADDR DEBOT
genaddr $debot_name
debot_address=$(get_address)
echo DEPLOY DEBOT $debot_address
giver $debot_address
debot_abi=$(cat $debot_name.abi.json | xxd -ps -c 20000)

./tonos-cli deploy $debot_name.tvc "{}" --sign $debot_name.keys.json --abi $debot_name.abi.json
./tonos-cli call $debot_address setABI "{\"dabi\":\"$debot_abi\"}" --sign $debot_name.keys.json --abi $debot_name.abi.json

echo DONE
echo $debot_address > address.log
echo debot  $debot_address

./tonos-cli debot fetch $debot_address