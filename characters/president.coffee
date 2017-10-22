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
        console.log 'hello the trigger!!'
        context.trigger = "president:red"
    else if bodyContainsEither(body, green_rhymes)
        intent = 'green'
        context.trigger = "president:green"
    else
        intent = 'frankly'

    cb null, {intent, context}

buildResponseFromIntent = (context, intent, cb) ->
    response_template = context.response_template_type || intent
    body = nalgene.generate grammar, null, "%#{response_template}"
    console.log 'CONTET', context
    cb null, {body, intent, context}

President = new BotforestBot('president', parseMessage, buildResponseFromIntent, methods)

# The man straightens and his eyes dart to the desk. He holds one hand out and moves silently to stand beside the array of phones and buttons. He picks up the phone on the left and stares out the window wordlessly. Five seconds pass. Then, "Do it.", he utters. He slams the phone down and presses his palm to the Green Button. The chain of events henceforth kill you and everything else on Earth.
# The man stiffens and his face takes a grave shape.

# The man becomes irate. -- These maniacs -- He gestures toward the cieling wildly. -- I told them, step out and we all go down! Well we have to show them... -- He moves to the desk, picks up the phone on the right, and hurls it into the glass of the closest window. The glass, bulletproof, absorbs the phone with little sound. The man screams in disgust and whirls around, pressing hard on the red button. The desk explodes, vaporizing every living thing within a hundred mile radius.

module.exports = President