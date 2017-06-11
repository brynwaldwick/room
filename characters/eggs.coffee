BotforestBot = require './botforest-bot'
nalgene = require 'nalgene'

grammar = nalgene.parse '''
    %hi
        'i
        haci!

    %girlPrettyResponse
        chrrrrrrr'!
        brill, brill, brill!
        goonchi, ... goonchi!
        Wooo

    %fallback
        mm?
        e?
        chr?
'''

girl_triggers = ['girl', 'she', 'her', 'mary']
good_triggers = ['beautiful', 'pretty', 'nice', 'like', 'great', 'amazing', 'kind']
who_am_i_triggers = ['doing', 'who', '?']
hello_triggers = [' hi', 'hello', ' hey']

intents = {
    'hi':
        trigger_words: hello_triggers

    'girlPrettyResponse':
        trigger_words: [
            '$and',
            girl_triggers,
            good_triggers
        ]
        commands: [
            cmd: "incMood"
            args: 0.02
        ]
    'whoAmI':
        trigger_words: [
            who_am_i_triggers
        ]
}

{bodyContainsEither, bodyContains} = require './helpers'

parseMessage = (context, body, cb) ->
    {location, topic, mood} = context
    if bodyContainsEither(body, girl_triggers) && bodyContainsEither(body, good_triggers)
        intent = 'girlPrettyResponse'
    else if bodyContainsEither(body, hello_triggers)
        intent = 'hi'
    else if bodyContainsEither(body, who_am_i_triggers)
        intent = 'whoAmI'

    cb null, {intent, context}

generateResponse = (context, intent, cb) ->
    if !intent?.length
        intent = 'fallback'
    body = nalgene.generate grammar, null, "%" + intent
    cb null, {body, intent, context}

Eggs = new BotforestBot(parseMessage, generateResponse, {})
module.exports = Eggs
