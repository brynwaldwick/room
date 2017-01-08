_ = require 'underscore'
somata = require 'somata'
config = require '../config'
schema = require './schema'
generic = require 'data-service/generic'
orm = require('data-service/orm')(config.mongodb)

data_service = new somata.Service 'room:data'
generic_methods = generic(schema, data_service)

context = {
    location: 'Room'
    focus: 'Room'
    # Rule: you can move your focus to something in the same location
    # from a sub focus, but you can only move into a subfocus from the
    # focus above it. e.g. go from the girl's book to the table, but not
    # from the girl's book to the pens on the table.
    inventory: []
}

story = require '../story'

data_methods = {}

data_methods.saySomething = (something, cb) ->
    console.log '[saySomething] Saying', something
    cb null, {said: something}

parseMessage = (body, cb) ->
    console.log 'Parsing the body', body
    split_body = body.split ' '
    action = split_body[0] || 'inspect'
    target = split_body[1]
    console.log action
    console.log target
    # console.log story
    console.log 'The context is', context
    console.log story[context.location]?[context.focus]?.target
    console.log story[context.location]?.target

    if story[target]?
        Target = story[target]
    else if story[context.location]?[context.focus]?[target]?
        Target = story[context.location][context.focus][target]
    else if story[context.location]?[target]?
        Target = story[context.location][target]

    if action == 'inspect'
        if story[target]
            context.location = target
            context.focus = target
        else if story[context.location][target]?
            context.focus = target

    cb null, {target: 'Testjones', response: Target?[action] || Target}

data_methods.sendMessage = (new_message, cb) ->
    new_message.from ||= 'user'

    createAndPublishMessage new_message, (err, created_message) ->
        parseMessage new_message.body, (err, {target, command, response}) ->

            if response?
                _body = response
            else
                _body = "Nothing interesting."

            response_message = {
                body: _body
                from: 'room'
            }

            createAndPublishMessage response_message, cb

createAndPublishMessage = (new_message, cb) ->
    generic_methods.createMessage new_message, (err, created_message) ->
        data_service.publish "new_message", created_message
        cb null, created_message

data_methods.findMessages = (query, options, cb) ->
    generic_methods.findMessages query, options, (err, messages) ->
        cb err, messages.reverse()

data_service.methods = _.extend {}, generic_methods, data_methods
