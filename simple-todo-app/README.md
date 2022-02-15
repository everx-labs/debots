# Simple DeBot application

This is an example of a simple TODO application. The application consists of two contracts:

-   todoDebot.sol, contract of DeBot
-   todo.sol, smart contract containing TODO list

## How to try DeBot in the Surf

This DeBot is already deployed on blockchain

### https://net.ever.live/
DeBot address: 0:20c3279225a285dfef71efe97f67e823513068b36e79d5fc669899389f89382f

Open the link: [https://uri.ever.surf/debot/0:20c3279225a285dfef71efe97f67e823513068b36e79d5fc669899389f89382f?net=devnet](https://uri.ever.surf/debot/0:20c3279225a285dfef71efe97f67e823513068b36e79d5fc669899389f89382f?net=devnet)

![](../assets/net.everos.dev.png)

### main https://ever.live
DeBot address: 0:73a7ba235ac26029574f0e053b3f25ba4d536b8ba2c8dd5d10fb266c9035bc36

Open the link: [https://uri.ever.surf/debot/0:73a7ba235ac26029574f0e053b3f25ba4d536b8ba2c8dd5d10fb266c9035bc36](https://uri.ever.surf/debot/0:73a7ba235ac26029574f0e053b3f25ba4d536b8ba2c8dd5d10fb266c9035bc36)

![](../assets/main.ton.dev.svg)

-   On the first launch DeBot deploys TODO contract with initial balance = 0.2 ever tokens, so you need to have a Surf wallet with positive balance.

-   DeBot will ask for your public key every time you launch it. It's inconvenient, but inevitable for now.

## How to build

### Prerequisites

npm, node.js ver>=14

Install everdev globally

```
$ npm i everdev -g
$ everdev tonos-cli install
```

### Compile

```
$ everdev sol compile todo.sol
$ everdev sol compile todoDebot.sol
```

## How to deploy

if you use Evernode SE:

```
$ everdev se start
$ ./deploy_debot.sh todoDebot.tvc
```

if you use net.everos.dev:

-   set `GIVER_ADDRESS` variable in `deploy_debot.sh`
-   edit `../giver.keys.json` respectively

```
$ ./deploy_debot.sh todoDebot.tvc https://net.ton.dev
```

## Run DeBot 

Find instructions here: [How to try-DeBot](../README.md#how-to-try-debot)

## TODO

Encrypt data before saving to contract
