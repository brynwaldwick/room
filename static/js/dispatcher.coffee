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

    # CRUD options

    get: (type, query, cb) ->
        @remote 'getAs', @user._id, @account.slug, type, query, cb

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

    # Streaming versions of get and find, folding CRUD events into state of item(s)

    # get$: (type, query) ->
    #     item$ = @remote$ 'getAs', @user._id, @account.slug, type, query
    #     events$ = @subscribe$ "#{@account.slug}::item:#{query._id}"
    #     item$.concat(events$).scan(handleItemEvent)

    # find$: (type, query, options) ->
    #     items$ = @remote$ 'findAs', @user._id, @account.slug, type, query, options
    #     events$ = @subscribe$ "#{@account.slug}::type:#{type}"
    #     items$.concat(events$).scan(handleItemsEvent)

    # feed$: (query) ->
    #     events$ = @remote$ 'findEventsAs', @user._id, @account.slug, '*', null, 0
    #     events$.concat @subscribe$ "#{@account.slug}"

dispatcher = new Dispatcher
module.exports = dispatcher
window.dispatcher = dispatcher
