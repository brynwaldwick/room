BotforestBot = require './botforest-bot'
nalgene = require 'nalgene'

sally_grammar = nalgene.parse '''
    %hi
        Hi, whatever!
        Ok, hi wierdo.
        Shhh, it's class!
    %pens
        Don't touch them perve!
        Get out of here, wierdo!
        Stop!
    %flirt
        Teehee, stop :)
        Thanks :). Let's talk at lunch.
    %go_to_antechamber
        If you really want me to ;)
    %fallback
        wtf are you talking about lol!?
'''

go_triggers = ['go']
antechamber_triggers = ['antechamber']
pen_triggers = [' pen']
flirt_triggers = ['cute']

intents = {
}

methods = {}

{bodyContainsEither, bodyContains, hello_triggers} = require './helpers'

parseMessage = (context, body, cb) ->
    {location, topic, mood} = context

    if bodyContainsEither(body, go_triggers) && bodyContainsEither(body, antechamber_triggers)
        intent = 'go_to_antechamber'
        context.trigger = "sally:antechamber"
    else if bodyContainsEither(body, pen_triggers)
        intent = 'pens'
    else if bodyContainsEither(body, hello_triggers)
        intent = 'hi'
    else if bodyContainsEither(body, flirt_triggers)
        intent = 'flirt'
    else
        intent = 'fallback'

    cb null, {intent, context}

buildResponseFromIntent_sally = (context, intent, cb) ->
    response_template = context.response_template_type || intent
    body = nalgene.generate sally_grammar, null, "%#{response_template}"
    cb null, {body, intent, context}

Sally = new BotforestBot('sally', parseMessage, buildResponseFromIntent_sally, methods)
# Tim = new BotforestBot('tim', parseMessage, buildResponseFromIntent_tim, methods)

module.exports = {Sally}
