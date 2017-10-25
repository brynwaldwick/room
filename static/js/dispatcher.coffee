Kefir = require 'kefir'
KefirBus = require 'kefir-bus'
somata = require 'somata-socketio-client'

noop = -> # Sometimes you don't want anything to happen because the events will handle it

class Dispatcher
    remote: somata.remote.bind null, 'room:chat'
    remote$: somata.remote$.bind null, 'room:chat'
    subscribe$: somata.subscribe$.bind null, 'room:data'

    intents$: new KefirBus()

    setUser: (user) ->
        @user = user

    findMessages: (type, cb) ->
        if !cb
            cb = options
            options = null
        @remote 'findMessages', {client_key: window.client_key}, cb

    sendMessage: (message, cb=noop) ->
        @remote 'sendMessage', message, cb

    findMessages$: (query) ->
        items$ = @remote$ 'findMessages', query, =>
        items$

    newMessages$: ->
        new_items$ = @subscribe$ "new_message:#{window.client_key}"
        new_items$

    Restart: (client_key) ->
        @remote$ 'restartLevel', {client_key}

dispatcher = new Dispatcher
module.exports = dispatcher
window.dispatcher = dispatcher
