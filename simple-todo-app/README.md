# Simple DeBot application

This is an example of a simple TODO application. The application consists of two contracts:

-   todoDebot.sol, contract of DeBot
-   todo.sol, smart contract containing TODO list

## How to try DeBot in the Surf

This DeBot is already deployed on blockchain

### net.ton.dev
DeBot address: 0:ba06ea5c648ff6149e75a0a589becd827a2d959e42a34eb5e6ee29cb080bc552

Open the link: https://uri.ton.surf/debot?address=0%3Aba06ea5c648ff6149e75a0a589becd827a2d959e42a34eb5e6ee29cb080bc552&net=devnet

![](../assets/net.ton.dev.svg)

### main.ton.dev.
DeBot address: 0:73a7ba235ac26029574f0e053b3f25ba4d536b8ba2c8dd5d10fb266c9035bc36

Open the link: https://uri.ton.surf/debot?address=0%3A73a7ba235ac26029574f0e053b3f25ba4d536b8ba2c8dd5d10fb266c9035bc36 

![](../assets/main.ton.dev.svg)

-   On the first launch DeBot deploys TODO contract with initial balance = 0.2 ton tokens, so you need to have a Surf wallet with positive balance.

-   DeBot will ask for your public key every time you launch it. It's inconvenient, but inevitable for now.

## How to build

### Prerequisites

npm, node.js ver>=14

Install tondev globally

```
$ npm i tondev -g
$ tondev tonos-cli install
```

### Compile

```
$ tondev sol compile todo.sol
$ tondev sol compile todoDebot.sol
```

## How to deploy

if you use TON OS SE:

```
$ tondev se start
$ ./deploy_debot.sh todoDebot.tvc
```

if you use net.ton.dev:

-   set `GIVER_ADDRESS` variable in `deploy_debot.sh`
-   edit `../giver.keys.json` respectively

```
$ ./deploy_debot.sh todoDebot.tvc https://net.ton.dev
```

## Run DeBot 

Find instructions here: [How to try-DeBot](../README.md#how-to-try-debot)

## TODO

Encrypt data before saving to contract
