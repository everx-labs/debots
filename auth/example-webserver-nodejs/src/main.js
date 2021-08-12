const httpServer = require('./server')

const main = async () => {
    try {
        httpServer()
    } catch (e) {
        console.log(e)
    }
}

main()
