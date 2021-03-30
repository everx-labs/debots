# Simple DeBot application

This is an example of a simple TODO application. The application consists of two contracts:

-   todoDebot.sol, contract of DeBot
-   todo.sol, smart contract containing TODO list

## Prerequisites

 npm, node.js ver>=14

 Install tondev globally
 ```
 $ npm i tondev -g
 ```

## How to build

  ```
  $ tondev tonos-cli install
  $ tondev sol compile todo.sol
  $ tondev sol compile todoDebot.sol
  ```

## How to deploy

  if you use node SE: 
  ```
  $ tondev se start
  $ ./deploy_contract.sh todo.tvc
  $ ./deploy_debot.sh todoDebot.tvc
  ```

 if you use net.ton.dev:

  - set `GIVER_ADDRESS` variable in `deploy_debot.sh`
  - edit `../giver.keys.json` respectively

  ```
  $ ./deploy_contract.sh todo.tvc https://net.ton.dev
  $ ./deploy_debot.sh todoDebot.tvc  https://net.ton.dev
  ```

## Run DeBot

  ```
  $ ./tonos-cli --url http://127.0.0.1 debot fetch <address>
  or
  $ ./tonos-cli --url https://net.ton.dev debot fetch <address>
  ```

## TODO

  Encrypt data before saving to contract
