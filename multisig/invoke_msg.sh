#!/bin/bash
set -e
debot=0:09403116d2d04f3d86ab2de138b390f6ec1b0bc02363dbf006953946e807051e
debot_name=msigDebotv1

if [ $# -eq 0 ]; then
    echo "Builds internal message for Multisig DeBot with encoded transaction parameters."
    echo "Message can be sent later to DeBot to submit new multisig transaction."
    echo "USAGE:"
    echo "  ${0} RECIPIENT AMOUNT BOUNCE PAYLOAD"
    echo "    where:"
    echo "      RECIPIENT - required, TON address of funds recipient"
    echo "      AMOUNT - required, amount of nanotokens to transfer"
    echo "      BOUNCE - required, sets bounce flag: true or false"
    echo "      PAYLOAD - optional, internal message body for recipient smart contract (BOC encoded as base64)"
    echo ""
    echo "EXAMPLE:"
    echo "  ${0} 0:09403116d2d04f3d86ab2de138b390f6ec1b0bc02363dbf006953946e807051e 1000000000 true"
    exit 1
fi

tos=./tonos-cli
if $tos --version > /dev/null 2>&1; then
    echo "OK $tos installed locally."
else
    tos=tonos-cli
    if $tos --version > /dev/null 2>&1; then
        echo "OK $tos installed globally."
    else
        echo "$tos not found globally or in the current directory. Please install it and rerun script."
        exit
    fi
fi

if test -f "$debot_name.abi.json"; then
    echo "OK $debot_name.abi.json found."
else
    echo "$debot_name.abi.json not found in the current directory."
    exit
fi

PAYLOAD="${4:-\"\"}"

tonos-cli run $debot getInvokeMessage "{\"sender\":\"0:0000000000000000000000000000000000000000000000000000000000000000\",\"recipient\":\"$1\",\"amount\":$2,\"bounce\":$3,\"payload\":$PAYLOAD}"  --abi $debot_name.abi.json \
    | grep message | cut -d '"' -f 4 | tr '/+' '_-' | tr -d '='

