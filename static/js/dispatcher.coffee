Kefir = require 'kefir'
KefirBus = require 'kefir-bus'
somata = require 'somata-socketio-client'

noop = -> # Sometimes you don't want anything to happen because the events will handle it

class Dispatcher
    remote: somata.remote.bind null, 'room:data'
    remote$: somata.remote$.bind null, 'room:data'
    subscribe$: somata.subscribe$.bind null, 'room:data'

    setUser: (user) ->
        @user = user

    findMessages: (type, cb) ->
        if !cb
            cb = options
            options = null
        @remote 'findMessages', {}, cb

    sendMessage: (message, cb=noop) ->
        @remote 'sendMessage', message, cb

    findMessages$: (query) ->
        items$ = @remote$ 'findMessages', {}
        items$

    newMessages$: ->
        new_items$ = @subscribe$ "new_message"
        new_items$

dispatcher = new Dispatcher
module.exports = dispatcher
window.dispatcher = dispatcher
