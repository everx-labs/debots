const express = require('express')
const logger = require('morgan')
const createError = require('http-errors')
const bodyParser = require('body-parser')

const routes = require('./routes')

// This variable represent some persistent storage
const storage = new Map()

const app = express()

app.use(logger('dev'))

app.use(bodyParser.urlencoded({ extended: true }))

app.use((req, res, next) => {
    req.storage = storage
    next()
})

app.use('/', routes)

app.use(express.static('public'))

app.use((req, res, next) => {
    next(createError(404))
})

app.use((err, req, res, _) => {
    const { status, message } = err
    if (status) {
        res.status(status).send(message)
    } else {
        console.error(err.stack)
        res.status(500).send('Internal Server Error')
    }
})

module.exports = app
