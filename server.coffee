config = require './config'
polar = require 'somata-socketio'

app = polar config.api

app.get '/', (req, res) ->
    res.render 'app'

app.start()
