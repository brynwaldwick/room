BotforestBot = require './botforest-bot'
nalgene = require 'nalgene'

grammar = nalgene.parse '''

    %red
        I heard the word red!

    %green
        I heard the word green!

    %frankly
        Frankly my dear, I could care less. Though who has the effort?
        What are you mutterring about, my pet?
        Tell me again about the time under the apple tree.
        The most legible beings speak slowly. Again please?

    %fallback
        I am ignoring you
'''

# what happened?
# what are the phones for?
# war
# russia
# mexico
# europe/spain/germany/france
# drones
# airplanes/air force/ bombers
# ships/navy
# army
# terrorists


china_triggers = ['chinese', 'china', 'economy']
red_rhymes = [' red', 'read than', 'tread', 'bread', 'bred', ' cred']
green_rhymes = [' green']
president_triggers = ['man', 'potus', 'president']

intents = {
}

methods = {}

{bodyContainsEither, bodyContains} = require './helpers'

parseMessage = (context, body, cb) ->
    {location, topic, mood} = context
    console.log 'the context'
    if bodyContainsEither(body, red_rhymes)
        intent = 'red'
    else if bodyContainsEither(body, green_rhymes)
        intent = 'green'
    else
        intent = 'frankly'

    cb null, {intent, context}

buildResponseFromIntent = (context, intent, cb) ->
    response_template = context.response_template_type || intent
    body = nalgene.generate grammar, null, "%#{response_template}"
    cb null, {body, intent, context}

President = new BotforestBot(parseMessage, buildResponseFromIntent, methods)

module.exports = President