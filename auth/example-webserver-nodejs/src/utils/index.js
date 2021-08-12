const pubkeyRegex = /^[0-9a-fA-F]{64}$/
const addressRegex = /^-?[0-9a-fA-F]+:[0-9a-fA-F]{64}$/
const onlyZero = /^0+$/

// :: String -> String
const strip0x = (str) => str.replace(/^0x/, '')
const add0x = (str) => (str === '' ? '' : `0x${strip0x(str)}`)
const stripWorkchain = (str) => str.replace(/^[^:]*:/, '')

// :: * -> Bool
const isValidPublicKey = (x) => typeof x === 'string' && pubkeyRegex.test(strip0x(x)) && !onlyZero.test(strip0x(x))
const isValidAddress = (x) => typeof x === 'string' && addressRegex.test(x) // && !onlyZero.test(stripWorkchain(x))

// :: String -> String
const convert = (from, to) => (data) => Buffer.from(data, from).toString(to)
const base64ToUtf8 = convert('base64', 'utf8')
const hexToUtf8 = (hex) => convert('hex', 'utf8')(strip0x(hex))
const hexToBase64 = (hex) => convert('hex', 'base64')(strip0x(hex))
const utf8ToHex = convert('utf8', 'hex')

const sleep = (ms = 0) => new Promise((resolve) => setTimeout(resolve, ms))
const expressTryCatch = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next)

module.exports = {
    add0x,
    convert,
    strip0x,
    stripWorkchain,
    expressTryCatch,
    isValidPublicKey,
    isValidAddress,
    sleep,
    base64ToUtf8,
    hexToUtf8,
    hexToBase64,
    utf8ToHex,
}
