const TON_SERVER = 'https://net.ton.dev'
const DEBOT_ADDRESS = process.argv[2]
const EXPRESS_PORT = process.argv[3] || 8080
const HOST = 'localhost'

if (!DEBOT_ADDRESS) throw Error('DeBot Address required')

const config = {
    pinLength: 4,
    attemptsLimit: 1,
    debotAddress: DEBOT_ADDRESS,
    express: { port: EXPRESS_PORT },
    callbackUrl: `http://${HOST}:${EXPRESS_PORT}/signature`,
    warningText: `Attention! You authorize access to ${HOST} site`,
    deeplinkBuilder: (adr, msg) =>
        `https://uri.ton.surf/debot/${adr}?net=devnet&message=${msg}`,
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
