# Repository for DeBots

## What is DeBot?
TODO: It is a smart contract...

## Debot interfaces

TODO: Maybe, a few words about interfaces.

Inteface specifications can be found here:

[https://github.com/tonlabs/DeBot-IS-consortium](https://github.com/tonlabs/DeBot-IS-consortium)

## Prerequisites

Download [`tonos-cli`](https://github.com/tonlabs/tonos-cli) version 0.8.1 or greater from here:

TODO: change paths to 0.8.1 archive

- `linux` http://sdkbinaries.tonlabs.io/tonos-cli-0_8_0-linux.zip
- `macos` http://sdkbinaries.tonlabs.io/tonos-cli-0_8_0-darwin.zip
- `windows` http://sdkbinaries.tonlabs.io/tonos-cli-0_8_0-windows.zip

## Debots

- `helloworld` - Hello World DeBot. Can be used as a template for new DeBots.
- `multisig` - DeBot for multisignature wallet. Uses sevral basic debot interfaces: Terminal, AddressInput, AmountInput, ConfirmInput.
- `TODO: need to add one more debot as sample`

### How to Build DeBot

DeBot can be built as any other smart contract.

TODO: give a link on instruction how to compile and link smart contract.

## How to Deploy

### Deploy to local node

Run `node SE`. (link to instrunction how to run node SE).

Run `deploy_debot.sh` script.

## How to Run

### Run in node SE

    ./tonos-cli --url http://127.0.0.1 debot fetch <address>

### Run in net.ton.dev

    ./tonos-cli --url net.ton.dev debot fetch <address>

### Run in mainnet

    ./tonos-cli --url main.ton.dev debot fetch <address>

## Futher Reading

Maybe add links to ton.dev to debot specs.