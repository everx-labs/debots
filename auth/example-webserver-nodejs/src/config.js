const TON_SERVER = 'https://net.ton.dev'
const DEBOT_ADDRESS = process.argv[2]
const EXPRESS_PORT = process.argv[3] || 8080

if (!DEBOT_ADDRESS) throw Error('DeBot Address required')

const config = {
    pinLength: 4,
    attemptsLimit: 1,
    debotAddress: DEBOT_ADDRESS,
    express: { port: EXPRESS_PORT },
    callbackUrl: `http://localhost:${EXPRESS_PORT}/signature`,
    deeplinkBuilder: (adr, msg) =>
        `https://ton-surf-alpha.firebaseapp.com/debot?address=${adr}&message=${msg}&net=devnet`,
    clientParams: {
        network: {
            server_address: TON_SERVER,
        },
    },
    contracts: {
        debot: {
            package: require('../../AuthDebotContract').AuthDebotContract,
        },
    },
}

const get = (target, prop) =>
    target[prop] !== undefined ? target[prop] : (console.log('E_NO_PROP', prop), process.exit(1))

module.exports = new Proxy(Object.freeze(config), { get })
