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

# story = require '../levels/level_1_room'
# story = require('../levels/level_2_office').story

levelIndexFromClientKey = (client_key) ->
    if client_key?.split(':')[0] == 'levels'
        return client_key?.split(':')[1]
    else
        return 1

stories = [
    {name: "Nothing here"},
    require('../levels/level_1_room').story,
    require('../levels/level_2_office').story
    require('../../room-private/levels/level_3_school').story
    require('../../room-private/levels/level_4_bank').story
    require('../../room-private/levels/level_5_hospital').story
    require('../../room-private/levels/level_6_windmill').story
]

characters =
    "gargoyle": require '../characters/gargoyle'
    "gardener": require '../characters/gardener'
    "eggs": require '../characters/eggs'
    "aviana": require '../characters/aviana'
    "teller1": require '../characters/tellerbot'
    "teller2": require '../characters/tellerbot'
    "hunchback": require '../../room-private/characters/hunchback'
    "chicken": require '../../room-private/characters/chicken'
    # "president": require '../characters/president'

President = require '../characters/president'

data_methods = {}

data_methods.saySomething = (something, cb) ->
    console.log '[saySomething] Saying', something
    cb null, {said: something}

filler_words = ['a', 'the', 'my', 'up', 'with', 'at',
    'to', 'out', 'in', 'into', 'but', 'through', 'some']

trimFillerWords = (body) ->
    result = body
    filler_words.map (w) ->
        regEx = new RegExp(" " + w + " ", "ig")
        result = result.replace regEx, " "

    return result

parseMessage = (body, cb) ->
    split_body = trimFillerWords(body).split ' '
    action = split_body[0] || 'inspect'
    action = action.toLowerCase()
    target = split_body[1..].join ' '
    console.log 'Action', action
    console.log 'Target', target
    cb null, {action, target}


applyIntentToSession = ({target, action}, context, cb) ->

    story = context.story
    # if context.level == 1
        # if the gargoyle falls, the narrator describes it
        # also the person picks up the key
        # if context.last_topic = 'hallway_far_door_combo'
            # response_message = {
            #     body: "What is the combo?"
            #     form: {
            #         combo: {optional: false}
            #     }
            # }


    # else if context.level == 2
        # aviana talks, president listens

    if target == 'around' && action == 'look'
        return cb null, story[context.location]?.inspect

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

base_contexts = [
    level: 0
    dead: false
,
    level: 1
    dead: false
    winner: false
    location: 'Room'
    focus: 'Room'
    topic: ''
    inventory: []
    gargoyle:
        mood: 0.5
        dead: false
    gardener:
        mood: 0.5
    Hallway:
        key: false
        far_door: 'locked'
    egg: false
    room_door: 'closed'
,
    level: 2
    dead: false
    winner: false
    location: 'Room'
    focus: 'Room'
    topic: ''
    inventory: []
    aviana: {}
    president: {}
    man:
        mood: 0.5
,
    level: 3
    dead: false
    winner: false
    location: 'Room'
    focus: 'Room'
    inventory: []
    mr_wallace:
        mood: 0.2
,
    level: 4
    dead: false
    winner: false
    location: 'Lobby'
    focus: 'Lobby'
    inventory: []
    tokens: 0
    teller1:
        topic: null
        in_the_strongroom: false
    teller2:
        topic: null
        in_the_strongroom: false
,
    level: 5
    dead: false
    winner: false
    location: 'Room'
    focus: 'Room'
    inventory: []
    trillvillion:
        topic: null
    nurse:
        topic: null
    bartender:
        topic: null
,
    level: 6
    dead: false
    winner: false
    location: 'Room'
    focus: 'Room'
    inventory: []
    hunchback:
        topic: null
        dialog_index: 0
        done_talking: false
    chicken:
        topic: null
        dialog_index: 0
        done_talking: false
    bartender:
        topic: null
]

data_methods.sendMessage = (new_message, cb) ->
    console.log 'the new message', new_message
    new_message.from ||= 'user'

    if new_message.client_key?.split(':')[0] == 'levels'
        level_index = levelIndexFromClientKey new_message.client_key
        base_context = base_contexts[level_index]

        story = stories[level_index]
    else
        story = stories[1]

    contexts[new_message.client_key] ||= Object.assign({}, base_context)
    _context = contexts[new_message.client_key]
    last_topic = '' + _context.topic
    console.log 'the context', _context
    console.log 'this was the last topic', last_topic
    _context.topic = ''
    {location, focus} = _context

    createAndPublishMessage new_message, (err, created_message) ->
        console.log _context
        if _context.dead == true
            response_message = {
                body: "You are dead. >Restart the level."
                from: 'Room'
                actions: [
                    trigger: '>Restart'

                ]
                client_key: new_message.client_key
            }
            createAndPublishMessage response_message, cb

        else if matched = new_message.body.match /\@([\w]*)/g
            message_to_character = true
            target = matched[0][1..]
            name = helpers.capitalize target
            console.log name
            console.log target
            console.log characters[target]
            if characters[target]? && (story[location][name]? ||
                    story[location]?[focus]?[name]?)
                # previous context of messages from the person
                topic = "room"
                message_context = {
                    location
                    mood: _context[target]?.mood
                    dead: _context[target]?.dead
                    dialog_index: _context[target]?.dialog_index
                    topic: _context[target]?.topic || "room"
                    my_tokens: _context.tokens || 0
                    data: _context[target]?.data || {}
                    channel: new_message.client_key
                }

                characters[target].handleMessage message_context, new_message.body, (err, response) ->

                    if response?.context?.mood
                        _context[target].mood = response.context.mood
                    if response?.context?.topic
                        _context[target].topic = response.context.topic
                        console.log 'im setting the topic', response.context.topic
                    if response?.context?.data
                        _context[target].data = response.context.data
                        console.log 'im setting the data', response.context.data
                        if response?.context?.data?.my_tokens?
                            console.log 'an was it here""???'
                            _context.tokens = response.context.data.my_tokens
                    if response?.context?.dialog_index
                        _context[target].dialog_index = response.context.dialog_index

                    console.log 'and the context', _context
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

                        else if response_message.from == 'aviana'
                            _context.channel = response_message.channel || response_message.client_key
                            President.handleMessage _context, body, (err, response) ->
                                if response.body?
                                    createAndPublishMessage {
                                        body: response.body
                                        from: 'president'
                                        client_key: new_message.client_key
                                    }, (err, message_response) ->
                                        console.log 'hello', err, message_response

            else
                response_message = {
                    body: "They aren't here"
                    from: 'Room'
                    client_key: new_message.client_key
                }

                createAndPublishMessage response_message, cb
        else
            parseMessage new_message.body, (err, {target, action, command, response}) ->
                if action == 'inventory'
                    body = "You have " + (
                        if _context.inventory.length
                            _context.inventory[0] + _context.inventory[1..-1].map (i) -> ", #{i}"
                        else
                            "nothing."

                    )
                    if _context?.tokens > 0
                        body = body.replace("You have", "You have #{_context.tokens} tokens, and ")
                    response_message = {
                        body
                        from: 'Room'
                        client_key: new_message.client_key
                    }

                    createAndPublishMessage response_message, cb
                else
                    _context.story = story
                    deconstructed_target = target.split(' ')

                    if action == 'unlock' && deconstructed_target[0..1].join(" ") == 'far door'
                        console.log 'Looks like they tried to unlock the far door'
                        combo = deconstructed_target[2]
                        if combo?
                            target = 'far door'
                            action = 'unlock'
                            combo = combo.replace(/-/g,'').replace(/,/g,'').replace(/\s+/g,'')
                            _context.last_combo_guess = combo

                    applyIntentToSession {target, action}, _context, (err, response) ->
                        delete _context.story
                        if response?
                            {form, item, items, lists} = response
                            if _.isString response
                                _body = response
                            else if response.body?
                                _body = response.body
                            else
                                _body = 'Error.'
                        else
                            _body = "Nothing interesting."

                        response_message = {
                            body: _body
                            from: 'Room'
                            client_key: new_message.client_key
                            form, item, items, lists
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
            level_index = levelIndexFromClientKey query.client_key
            setTimeout =>
                new_message = {
                    from: 'Room'
                    body: stories[level_index].Room.inspect
                    client_key: query.client_key
                }
                createAndPublishMessage new_message, ->
            , 1234

# data_methods.restartLevel = (query, cb) ->
#     {client_key} = query
#     generic_methods.findMessages {client_key}, (err, messages) ->
#         async.map messages, generic_methods
#         TODO: ...

data_service.methods = _.extend {}, generic_methods, data_methods

