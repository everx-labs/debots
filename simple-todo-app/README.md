# Simple DeBot application

This is an example of a simple TODO application. The application consists of two contracts:

-   todoDebot.sol, contract of DeBot
-   todo.sol, smart contract containing TODO list

## Prerequisites

 npm, node.js ver>=14

 Install everdev globally
 ```
 $ npm i everdev -g
 ```

## How to build

  ```
  $ everdev tonos-cli install
  $ everdev sol compile todo.sol
  $ everdev sol compile todoDebot.sol
  ```

## How to deploy

  if you use node SE: 
  ```
  $ everdev se start
  $ ./deploy_contract.sh todo.tvc
  ```
  Remember this address, debot will ask it
  ```
  $ ./deploy_debot.sh todoDebot.tvc
  ```

 if you use net.ton.dev:

  - set `GIVER_ADDRESS` variable in `deploy_debot.sh`
  - edit `../giver.keys.json` respectively

  ```
  $ ./deploy_contract.sh todo.tvc https://net.ton.dev
  ```
  Remember this address, debot will ask it
  ```  
  $ ./deploy_debot.sh todoDebot.tvc  https://net.ton.dev
  ```

## Run DeBot

  ```
  $ tonos-cli --url http://127.0.0.1 debot fetch <address>
  or
  $ tonos-cli --url https://net.ton.dev debot fetch <address>
  ```
  When debot asks for keys, write "todo.keys.json"

## TODO

  Encrypt data before saving to contract
