# Simple DeBot application

This is an example of a simple TODO application. The application consists of two contracts:

-   todoDebot.sol, contract of DeBot
-   todo.sol, smart contract containing TODO list

## How to try DeBot in the Surf

This DeBot is already deployed on blockchain

### net.ton.dev
DeBot address: 0:ba06ea5c648ff6149e75a0a589becd827a2d959e42a34eb5e6ee29cb080bc552

Open a link: https://uri.ton.surf/debot?address=0%3Aba06ea5c648ff6149e75a0a589becd827a2d959e42a34eb5e6ee29cb080bc552&net=net.ton.dev or scan
![](net.ton.dev.svg)

### main.ton.dev.
DeBot address: 0:73a7ba235ac26029574f0e053b3f25ba4d536b8ba2c8dd5d10fb266c9035bc36

Open a link: https://uri.ton.surf/debot?address=0%3A73a7ba235ac26029574f0e053b3f25ba4d536b8ba2c8dd5d10fb266c9035bc36 or scan
![](main.ton.dev.svg)

-   On the first launch DeBot deploys TODO contract with initial balance = 0.2 Ruby, so you have a Surf wallet with positive balance.

-   DeeBot will ask for your public key every time you launch it. It's inconvenient, but inevitable for now.

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

## Run DeBot in the Surf (net.ton.dev)

Open this link https://ton-surf-alpha.firebaseapp.com/debot?address=<your_debot_address>&net=devnet

DeBot will ask you for your public key.

## Run DeBot in the terminal

1. Prepare file with you keys or seed phrase. You need it to sign transactions, e.g.:

```
$ cat todo.keys.json
  {
    "public": "8bd0i...3f",
    "secret": "a3c46...96"
  }
```

2. Run DeBot

TON OS SE:

```
$ tonos-cli --url http://127.0.0.1 debot fetch <address>
```

net.ton.dev:

```
$ tonos-cli --url https://net.ton.dev debot fetch <address>
```

When debot asks you to sign transaction, write "todo.keys.json"

## TODO

Encrypt data before saving to contract
