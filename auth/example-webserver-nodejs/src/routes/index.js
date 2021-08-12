/* eslint-disable no-use-before-define */
/* eslint-disable no-console */

const qr = require('qrcode')
const uuidv4 = require('uuid/v4')
const express = require('express')
const { libNode } = require('@tonclient/lib-node')
const { Account } = require('@tonclient/appkit')
const { TonClient } = require('@tonclient/core')

const { expressTryCatch, utf8ToHex } = require('../utils')
const {
    attemptsLimit,
    callbackUrl,
    warningText,
    clientParams,
    contracts,
    debotAddress,
    deeplinkBuilder,
    pinLength,
} = require('../config')

const AUTH_UNKNOWN = 'AUTH_UNKNOWN'
const AUTH_OPEN = 'AUTH_OPEN'
const AUTH_SUCCEEDED = 'AUTH_SUCCEEDED'
const AUTH_FAILED = 'AUTH_FAILED'

TonClient.useBinaryLibrary(libNode)
TonClient.defaultConfig = clientParams
const client = TonClient.default

const router = express.Router()

router.get('/status', expressTryCatch(getStatus))
router.get('/qrcode', expressTryCatch(getQrCode))
router.post('/signature', expressTryCatch(postSignature))

function getStatus(req, res) {
    const that = req.storage.get(req.query.id)
    res.send({ status: that ? that.status : AUTH_UNKNOWN })
}

async function getQrCode(req, res) {
    const id = uuidv4() // generate some session id
    const otp = uuidv4() // generated one time password

    const pinRequired = req.query.pin === 'true' // set flag if PIN required

    const pin = pinRequired
        ? Math.random() // generated PIN from random number
              .toString()
              .slice(2, pinLength + 2)
        : ''

    const debot = new Account(contracts.debot.package, {
        address: debotAddress,
    })

    // Create a DeBot invoke message with required parameters
    const message = await debot
        .runLocal('getInvokeMessage', {
            id: utf8ToHex(id),
            otp: utf8ToHex(otp),
            pinRequired,
            callbackUrl: utf8ToHex(callbackUrl),
            warningText: utf8ToHex(warningText),
        })
        .then((result) =>
            // convert from base64 to base64url
            result.decoded.output.message
                .replace(/\//g, '_')
                .replace(/\+/g, '-')
                .replace(/=/g, ''),
        )

    const deeplink = deeplinkBuilder(debotAddress, message)

    // Remember the generated values in a local storage
    req.storage.set(id, {
        otp,
        pin,
        status: AUTH_OPEN,
        attempts: 0,
    })

    // Send QR and PIN to the frontend
    res.json({
        id,
        pin,
        deeplink,
        qrbase64: await qr.toDataURL(deeplink, { version: 16 }),
    })
}

async function postSignature(req, res) {
    const { id, signature, pk } = req.body

    // Set headers due to Cross-Origin Resource Sharing (CORS)
    res.setHeader('Access-Control-Allow-Origin', '*')

    if (!req.storage.has(id)) return res.sendStatus(404)

    const that = req.storage.get(id)

    try {
        if (that.attempts > attemptsLimit) throw Error('Too many attempts')

        const { hash } = await client.crypto.sha256({
            data: Buffer.from(`${that.otp}${that.pin}${callbackUrl}${warningText}`, 'utf-8').toString('base64'),
        })

        const { succeeded } = await client.crypto.nacl_sign_detached_verify({
            unsigned: Buffer.from(hash, 'hex').toString('base64'),
            signature: Buffer.from(signature.replace(/ /g, '+'), 'base64').toString('hex'),
            public: pk,
        })

        if (!succeeded) throw Error('Sign check failed')

        req.storage.set(id, { ...that, status: AUTH_SUCCEEDED })
        return res.sendStatus(200)
    } catch (err) {
        console.log(err)
        req.storage.set(id, { ...that, status: AUTH_FAILED, attempts: that.attempts + 1 })
        return res.sendStatus(403)
    }
}

module.exports = router
