Kefir = require 'kefir'
KefirBus = require 'kefir-bus'
somata = require 'somata-socketio-client'

noop = -> # Sometimes you don't want anything to happen because the events will handle it

class Dispatcher
    remote: somata.remote.bind null, 'room:data'
    remote$: somata.remote$.bind null, 'room:data'
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
        console.log 'quality', query
        items$ = @remote$ 'findMessages', query, =>
        items$

    newMessages$: ->
        new_items$ = @subscribe$ "new_message:#{window.client_key}"
        new_items$

dispatcher = new Dispatcher
module.exports = dispatcher
window.dispatcher = dispatcher
