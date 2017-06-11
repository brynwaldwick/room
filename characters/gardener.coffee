BotforestBot = require './botforest-bot'
nalgene = require 'nalgene'

grammar = nalgene.parse '''
    %dontWant
        I don't want to talk.
        Leave me to it, please.

    %aboutGargoyle
        That fuckin' gargoyle.
        Guy's a right arse.

    %aboutGirl
        I just want to go in there and see her.

    %aboutGarden
        Mutant vegetables.
'''

garden_triggers = ['vegetables', 'plant', 'grow']
girl_triggers = ['girl', 'inside', 'mary']
gargoyle_triggers = ['gargoyle', 'house']

intents = {
    'aboutGargoyle': {
        trigger_words: gargoyle_triggers
    }
    'aboutGirl': {
        trigger_words: girl_triggers
    }
    'aboutGarden': {
        trigger_words: garden_triggers
    }
}

{bodyContainsEither, bodyContains} = require './helpers'

parseMessage = (context, body, cb) ->
    {location, topic, mood} = context
    if bodyContainsEither(body, girl_triggers)
        intent = 'aboutGirl'
    else if bodyContainsEither(body, garden_triggers)
        intent = 'aboutGarden'
    else if bodyContainsEither(body, gargoyle_triggers)
        intent = 'aboutGargoyle'

    cb null, {intent, context}

generateResponse = (context, intent, cb) ->
    if !intent?.length
        intent = 'dontWant'
    body = nalgene.generate grammar, null, "%" + intent
    cb null, {body, intent, context}

Gardener = new BotforestBot(parseMessage, generateResponse, {})
module.exports = Gardener
