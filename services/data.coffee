async = require 'async'
DataService = require 'data-service'
config = require '../config'

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
        in_forest: false
    figure:
        appeared: false
        in_forest: false
]

stories = [
    {name: "Nothing here"},
    require('../levels/level_1_room').story,
    require('../levels/level_2_office').story
    require('../../room-private/levels/level_3_school').story
    require('../../room-private/levels/level_4_bank').story
    require('../../room-private/levels/level_5_hospital').story
    require('../../room-private/levels/level_6_windmill').story
]

levelIndexFromClientKey = (client_key) ->
    if client_key?.split(':')[0] == 'levels'
        return client_key?.split(':')[1]
    else
        return 1

data_methods = {}

data_methods.findMessages = (query, cb) ->
    find 'messages', query, {}, {sort: '_id', sort_dir: 'asc', all: true}, (err, messages) ->
        cb err, messages

# TODO: move the publishing to an "engine", which is in charge of subscriptions
# and resulting actions??

data_methods.createAndPublishMessage = (new_message, cb) ->
    create 'messages', new_message, (err, created_message) ->
        data_service.publish "new_message:#{new_message.client_key}", created_message
        cb null, created_message

data_methods.getOrCreateContext = (client_key, cb) ->
    get 'contexts', {client_key}, (err, context) ->
        return cb err if err?
        if context?
            cb err, context
        else
            level_index = levelIndexFromClientKey client_key
            base_context = base_contexts[level_index]
            new_context = Object.assign({}, base_context, {client_key})
            create 'contexts', new_context, (err, created_context) ->
                cb err, created_context

data_methods.updateContext = (client_key, context_update, cb) ->
    get 'contexts', {client_key}, (err, context) ->
        update 'contexts', context.id, context_update, (err, updated_context) ->
            cb null, updated_context

data_methods.restartLevel = (query, cb) ->
    {client_key} = query
    console.log 'hi there', query
    find 'messages', {client_key}, null, {all: true}, (err, messages) ->
        console.log 'the messages', err, messages
        async.map messages, (message, _cb) ->
            data_service.methods.remove 'messages', message.id, _cb
        , cb

data_service = new DataService 'room:data', {
    type: 'mongo'
    config: {
        host: config?.mongo?.host or 'localhost'
        db: config?.mongo?.db or 'room'
        id_key: 'id'
        strict_auth: false
    }
}, data_methods

aws_auth = config.aws_auth
    
# data_service = new DataService 'room:data', {
#     type: 'dynamo'
#     config: {
#         project_slug: "room"
#         aws_auth
#         db: config?.dynamo?.db or 'room'
#         id_key: 'id'
#         strict_auth: false
#     }
# }, data_methods

{get, create, update, find} = data_service.methods
