const uuidv4 = require('uuid/v4')
const qr = require('qrcode')
const express = require('express')
const { libNode } = require('@tonclient/lib-node')
const { Account } = require('@tonclient/appkit')
const { TonClient } = require('@tonclient/core')

const { expressTryCatch, utf8ToHex } = require('../utils')
const {
    clientParams,
    contracts,
    pinLength,
    debotAddress,
    deeplinkBuilder,
    callbackUrl,
    attemptsLimit,
} = require('../config')

const AUTH_UNKNOWN = 'AUTH_UNKNOWN'
const AUTH_OPEN = 'AUTH_OPEN'
const AUTH_SUCCEEDED = 'AUTH_SUCCEEDED'
const AUTH_FAILED = 'AUTH_FAILED'

TonClient.useBinaryLibrary(libNode)
TonClient.defaultConfig = clientParams
const client = TonClient.default

const state = new Map()

const getQrCode = async (req, res) => {
    const id = uuidv4()
    const otp = uuidv4()

    const pinRequired = req.query.pin === 'true'

    const pin = pinRequired
        ? Math.random()
              .toString()
              .slice(2, pinLength + 2)
        : ''

    const debot = new Account(contracts.debot.package, {
        address: debotAddress,
    })

    const message = await debot
        .runLocal('getInvokeMessage', {
            id: utf8ToHex(id),
            otp: utf8ToHex(otp),
            pinRequired,
            callbackUrl: utf8ToHex(callbackUrl),
        })
        .then((res) =>
            res.decoded.output.message
                .replace(/\//g, '_')
                .replace(/\+/g, '-')
                .replace(/=/g, ''),
        )

    const deeplink = deeplinkBuilder(debotAddress, message)

    state.set(id, {
        otp,
        pin,
        status: AUTH_OPEN,
        attempts: 0,
    })

    res.json({
        id,
        pin,
        deeplink,
        qrbase64: await qr.toDataURL(deeplink, { version: 16 }),
    })
}

const postSignature = async (req, res) => {
    const { id, signature, pk } = req.body
    res.setHeader('Access-Control-Allow-Origin', '*')

    if (!state.has(id)) return res.sendStatus(404)

    const that = state.get(id)
    console.log(that)

    try {
        if (that.attempts > attemptsLimit) throw 'Too many attempts'

        const { hash } = await client.crypto.sha256({
            data: Buffer.from(`${that.otp}${that.pin}`, 'utf-8').toString('base64'),
        })

        const { succeeded } = await client.crypto.nacl_sign_detached_verify({
            unsigned: Buffer.from(hash, 'hex').toString('base64'),
            signature: Buffer.from(signature.replace(/ /g, '+'), 'base64').toString('hex'),
            public: pk,
        })

        if (!succeeded) throw Error('Sign check failed')

        state.set(id, { ...that, status: AUTH_SUCCEEDED })
        res.sendStatus(200)
    } catch (err) {
        console.log(err)
        state.set(id, { ...that, status: AUTH_FAILED, attempts: that.attempts + 1 })
        res.sendStatus(403)
    }
}

const getStatus = (req, res) => {
    const that = state.get(req.query.id)
    res.send({ status: that ? that.status : AUTH_UNKNOWN })
}

const router = express.Router()

router.get('/qrcode', expressTryCatch(getQrCode))
router.get('/status', expressTryCatch(getStatus))
router.post('/signature', expressTryCatch(postSignature))

module.exports = router
