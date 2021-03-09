# Multisig Debot

Allows to manage wallet with multiple custodians.

## Supported Wallets

- [SafeMultisigWallet](https://github.com/tonlabs/ton-labs-contracts/blob/master/solidity/safemultisig/SafeMultisigWallet.tvc)
- [SetcodeMultisigWallet](https://github.com/tonlabs/ton-labs-contracts/blob/master/solidity/setcodemultisig/SetcodeMultisigWallet.tvc)

## How to deploy to node SE

Run `./debot_deploy.sh` script.


## How to run in node SE

    ./tonos-cli --url http://127.0.0.1 debot fetch <address>

## Run Multisig DeBot in mainnet

### using Surf

TODO: describe how to run debot in surf (address 0:09403116d2d04f3d86ab2de138b390f6ec1b0bc02363dbf006953946e807051e)

### using tonos-cli

    ./tonos-cli --url main.ton.dev debot fetch 0:09403116d2d04f3d86ab2de138b390f6ec1b0bc02363dbf006953946e807051e


