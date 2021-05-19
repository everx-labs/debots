# DePool DeBot

Helps to manage stakes in DePools v3.

## How to build

    tondev sol compile depoolDebotv1.sol

## How to deploy to TON OS SE

Start TON OS SE

    tondev se start

Run script

    ./deploy_debot.sh

## How to run in TON OS SE

Instal tonos-cli:

    tondev tonos-cli install

Run DeBot:

    tonos-cli --url http://127.0.0.1 debot fetch <address>
