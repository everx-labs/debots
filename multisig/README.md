# Multisig Debot

Allows to manage wallet with multiple custodians.

## Supported Wallets

- [SafeMultisigWallet](https://github.com/tonlabs/ton-labs-contracts/blob/master/solidity/safemultisig/SafeMultisigWallet.tvc)
- [SetcodeMultisigWallet](https://github.com/tonlabs/ton-labs-contracts/blob/master/solidity/setcodemultisig/SetcodeMultisigWallet.tvc)

## How to build

    tondev sol compile msigDebotv1.sol

## How to deploy to node SE

Start node SE

    tondev se start

Run script

    ./deploy_debot.sh

## How to run in node SE

    ./tonos-cli --url http://127.0.0.1 debot fetch <address>

## Run Multisig DeBot in mainnet
### using tonos-cli

    ./tonos-cli --url main.ton.dev debot fetch 0:09403116d2d04f3d86ab2de138b390f6ec1b0bc02363dbf006953946e807051e


