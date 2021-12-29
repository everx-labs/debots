# Multisig Debot

Allows to manage wallet with multiple custodians.

## Supported Wallets

- [SafeMultisigWallet](https://github.com/tonlabs/ton-labs-contracts/blob/master/solidity/safemultisig/SafeMultisigWallet.tvc)
- [SetcodeMultisigWallet](https://github.com/tonlabs/ton-labs-contracts/blob/master/solidity/setcodemultisig/SetcodeMultisigWallet.tvc)

## How to build

    everdev sol compile msigDebotv1.sol

## How to deploy to TON OS SE

Start TON OS SE

    everdev se start

Run script

    ./deploy_debot.sh

## How to run in TON OS SE

    ./tonos-cli --url http://127.0.0.1 debot fetch <address>

## Run Multisig DeBot in mainnet
### using tonos-cli

    ./tonos-cli --url main.ton.dev debot fetch 0:09403116d2d04f3d86ab2de138b390f6ec1b0bc02363dbf006953946e807051e

### How to create invoke message for Msig DeBot

Run script `.invoke_msg.sh` with debot arguments.

Run script `.invoke_msg.sh` without arguments for help.

Example:

    ./invoke_msg.sh 0:606545c3b681489f2c217782e2da2399b0aed8640ccbcf9884f75648304dbc77 1000000000 true

