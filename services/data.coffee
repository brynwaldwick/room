_ = require 'underscore'
somata = require 'somata'
config = require '../config'
schema = require './schema'
generic = require 'data-service/generic'
orm = require('data-service/orm')(config.mongodb)

data_service = new somata.Service 'room:data'
generic_methods = generic(schema, data_service)

contexts = {}
# {
#     location: 'Room'
#     focus: 'Room'
#     # Rule: you can move your focus to something in the same location
#     # from a sub focus, but you can only move into a subfocus from the
#     # focus above it. e.g. go from the girl's book to the table, but not
#     # from the girl's book to the pens on the table.
#     inventory: []
#     hallway_key: false
#     egg: false
#     room_door: 'closed'
# }

helpers = {
    capitalize: (s) ->
        if !s?.length then return ''
        s.split(" ").map((s) ->
            s[0].toUpperCase() + s.slice(1)).join ' '
}

story = require '../story'
characters =
    "gargoyle": require '../characters/gargoyle'
    "gardener": require '../characters/gardener'

data_methods = {}

data_methods.saySomething = (something, cb) ->
    console.log '[saySomething] Saying', something
    cb null, {said: something}

parseMessage = (body, cb) ->
    console.log 'Parsing the body', body
    split_body = body.split ' '
    action = split_body[0] || 'inspect'
    action = action.toLowerCase()
    target = split_body[1..].join ' '
    console.log 'Action', action
    console.log 'Target', target
    cb null, {action, target}


applyIntentToSession = ({target, action}, context, cb) ->

    console.log 'The context is', context
    target = helpers.capitalize target
    console.log target
    if action in ['go_to', 'goto']
        if target == context.location
            cb null, "You are here."
        else if story[context.location].neighbors[target]?
            response = story[context.location].neighbors[target](context)
            cb null, response

        else
            cb null, 'You cannot go there'
    else

        # if story[target]?
        #     Target = story[target]
        if target == context.location
            Target = story[context.location]
        else if story[context.location]?[context.focus]?[target]?
            Target = story[context.location][context.focus][target]
        else if story[context.location]?[target]?
            Target = story[context.location][target]

        # TODO: breakout into updateContext

        if action == 'inspect'
            # if story[target]
            #     context.location = target
            #     context.focus = target
            # if target isLocatedIn(story[context.location])
            #     context.focus = target
            if story[context.location][target]?
                context.focus = target

        # TODO: call into function
        if _.isFunction Target?[action]
            console.log 'you are a function'
            cb null, Target[action](context)
        else
            if action == 'inspect'
                cb null, Target?[action] || Target
            else
                cb null, Target?[action] || "Sorry, you can't."

data_methods.sendMessage = (new_message, cb) ->
    new_message.from ||= 'user'
    createAndPublishMessage new_message, (err, created_message) ->
        if matched = new_message.body.match /\@([\w]*)/g
            message_to_character = true
            target = matched[0][1..]
            if characters[target]?
                # previous context of messages from the person
                topic = "room"
                characters[target].parseMessage {topic, body: new_message.body}, (err, parsed_message) ->
                    characters[target].generateResponse parsed_message, (err, response) ->
                        console.log err, response
                        # TODO: handle characters' interpretations in story state
                        body = response.body || "They don't want to talk"
                        response_message = {
                            body
                            from: 'Room'
                            client_key: new_message.client_key
                        }

                        createAndPublishMessage response_message, cb
            else
                response_message = {
                    body: "They aren't here"
                    from: 'Room'
                    client_key: new_message.client_key
                }

                createAndPublishMessage response_message, cb
        else
            parseMessage new_message.body, (err, {target, action, command, response}) ->

                base_context = {
                    location: 'Room'
                    focus: 'Room'
                    inventory: []
                    hallway_key: false
                    egg: false
                    room_door: 'closed'}

                contexts[new_message.client_key] ||= base_context

                _context = contexts[new_message.client_key]

                applyIntentToSession {target, action}, _context, (err, response) ->

                    if response?
                        if _.isString response
                            _body = response
                        else
                            _body = 'Error.'
                    else
                        _body = "Nothing interesting."

                    response_message = {
                        body: _body
                        from: 'Room'
                        client_key: new_message.client_key
                    }

                    createAndPublishMessage response_message, cb

createAndPublishMessage = (new_message, cb) ->
    generic_methods.createMessage new_message, (err, created_message) ->
        data_service.publish "new_message:#{new_message.client_key}", created_message
        cb null, created_message

data_methods.findMessages = (query, cb) ->
    generic_methods.findMessages query, (err, messages) ->
        cb err, messages.reverse()

        if messages.length == 0
            setTimeout =>
                new_message = {
                    from: 'Room'
                    body: story.Room.inspect
                    client_key: query.client_key
                }
                createAndPublishMessage new_message, ->
            , 1234

data_service.methods = _.extend {}, generic_methods, data_methods
