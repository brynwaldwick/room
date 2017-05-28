config = require './config'
polar = require 'somata-socketio'
crypto = require 'crypto'

md5 = (s) -> crypto.createHash('md5').update(s).digest('hex')
getPublicClientKey = (session_id) -> md5(session_id)

client_info_middleware = (req, res, next) ->
    res.locals.ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress
    res.locals.ua = req.get('User-Agent')
    res.locals.session_id = req.session?.id
    res.locals.client_key = md5 res.locals.session_id
    next()

app = polar config.api, middleware: [client_info_middleware]

app.get '/', (req, res) ->
    res.render 'app'

app.get '/:thread_slug', (req, res) ->
    res.locals.client_key = req.params.thread_slug
    res.render 'app'

app.get '/levels/:level_int', (req, res) ->
    res.render 'app'

app.start()
