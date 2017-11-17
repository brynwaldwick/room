somata = require 'somata'
config = require './config'
polar = require 'somata-socketio'
crypto = require 'crypto'

client = new somata.Client()
DataService = client.remote.bind client, 'room:data'

md5 = (s) -> crypto.createHash('md5').update(s).digest('hex')
getPublicClientKey = (session_id) -> md5(session_id)

client_info_middleware = (req, res, next) ->
    res.locals.ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress
    res.locals.ua = req.get('User-Agent')
    res.locals.session_id = req.session?.id
    res.locals.client_key = md5 res.locals.session_id
    res.locals.level = {name: 'Room', index: 1}
    next()

levels = [
    {name: 'Nothing here'},
    require('./levels/level_1_room'),
    require('./levels/level_2_office')
    require('../room-private/levels/level_3_school'),
    require('../room-private/levels/level_4_bank'),
    require('../room-private/levels/level_5_hospital')
    require('../room-private/levels/level_6_windmill')
]

app = polar config.api, middleware: [client_info_middleware]

app.get '/', (req, res) ->
    res.render 'home'

app.get '/:thread_slug', (req, res) ->
    res.locals.client_key = req.params.thread_slug
    res.render 'app'

app.get '/levels/:level_index', (req, res) ->
    level_index = Number(req.params.level_index)
    if level_index in [1, 2, 3, 4, 5, 6]
        res.locals.client_key = "levels:#{req.params.level_index}:#{res.locals.client_key}"
        level = levels[level_index]
        {name, index} = level
        res.locals.level = {name, index}
        res.render 'app'
    else if level_index == 7
        res.redirect "http://book2.room.dev"

app.get '/level/:level_index', (req, res) ->
    level_index = Number(req.params.level_index)
    if level_index in [1, 2, 3]
        res.locals.client_key = "levels:#{req.params.level_index}:#{res.locals.client_key}"
        level = levels[level_index]
        {name, index} = level
        res.locals.level = {name, index}
        res.render 'app'

app.get '/levels/:level_index/restart', (req, res) ->
    DataService 'restartLevel', {client_key: res.locals.client_key}, (err, response) ->
        res.redirect '/levels/:level_int'

app.get '/level/:level_index/restart', (req, res) ->
    DataService 'restartLevel', {client_key: res.locals.client_key}, (err, response) ->
        res.redirect '/level/:level_int'

app.start()
