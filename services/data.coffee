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
#     hallway: false
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

filler_words = ['a', 'the', 'my', 'up', 'with',
    'to', 'out', 'in', 'into', 'but', 'through', 'some']

trimFillerWords = (body) ->
    result = body
    filler_words.map (w) ->
        regEx = new RegExp(" " + w + " ", "ig")
        result = result.replace regEx, " "

    return result

parseMessage = (body, cb) ->
    console.log 'Parsing the body', body
    split_body = trimFillerWords(body).split ' '
    action = split_body[0] || 'inspect'
    action = action.toLowerCase()
    target = split_body[1..].join ' '
    console.log 'Action', action
    console.log 'Target', target
    cb null, {action, target}


applyIntentToSession = ({target, action}, context, cb) ->

    target = helpers.capitalize target
    if action in ['go_to', 'goto', 'go', 'enter', 'walk']
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

        if action in ['inspect', 'look', 'watch', 'check out']
            action = 'inspect'

        if action in ['take', 'pick', 'grab', 'use']
            action = 'take'

        if action == 'inspect'
            # TODO: need recursive context searching
            # if target isLocatedIn(story[context.location])
            #     context.focus = target
            if story[context.location][target]?
                context.focus = target

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

    base_context = {
        level: 1
        location: 'Room'
        focus: 'Room'
        inventory: []
        gargoyle:
            mood: 0.5
            dead: false
        gardener:
            mood: 0.5
        Hallway:
            key: false
        egg: false
        room_door: 'closed'}

    contexts[new_message.client_key] ||= base_context

    _context = contexts[new_message.client_key]
    {location} = _context

    createAndPublishMessage new_message, (err, created_message) ->
        if matched = new_message.body.match /\@([\w]*)/g
            message_to_character = true
            target = matched[0][1..]
            name = helpers.capitalize target
            if characters[target]? && story[location][name]?
                # previous context of messages from the person
                topic = "room"
                message_context = {
                    location
                    mood: _context[target].mood
                    dead: _context[target].dead
                    topic
                }

                characters[target].handleMessage message_context, new_message.body, (err, response) ->

                    # TODO: use this more complete version


                # TODO: send stuff through with context
                # characters[target].parseMessage message_context, new_message.body, (err, parsed_message) ->
                #     {context, response} = parsed_message
                #     intent = response
                #     characters[target].buildResponseFromIntent context, intent, (err, response) ->

                        if response?.context?.mood
                            _context[target].mood = response?.context?.mood
                        # TODO: handle characters' interpretations in story state
                        body = response.body || "They don't want to talk"
                        response_message = {
                            body
                            from: target || 'Room'
                            client_key: new_message.client_key
                        }

                        createAndPublishMessage response_message, (err, character_message) ->
                            cb err, character_message
                            if response.context.trigger?
                                trigger_slug = response.context.trigger.split(':')[1]
                                Trigger = story[location][name]?.triggers?[trigger_slug]
                                if _.isFunction Trigger
                                    body = Trigger(_context)
                                else
                                    body = Trigger

                                if body?
                                    response_message = {
                                        body
                                        from: 'Room'
                                        client_key: new_message.client_key
                                    }

                                    createAndPublishMessage response_message, (err, narrator_message) ->
                                        console.log err if err?
                                        console.log 'Sent narrator message'
            else
                response_message = {
                    body: "They aren't here"
                    from: 'Room'
                    client_key: new_message.client_key
                }

                createAndPublishMessage response_message, cb
        else
            parseMessage new_message.body, (err, {target, action, command, response}) ->

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
