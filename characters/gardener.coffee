
grammar = '''
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

nalgene = require 'nalgene'
grammar = nalgene.parse grammar

{bodyContainsEither, bodyContains} = require './helpers'

parseMessage = (context, body, cb) ->
    {location, topic, mood} = context
    if bodyContainsEither(body, girl_triggers)
        response = '%aboutGirl'
    else if bodyContainsEither(body, garden_triggers)
        response = '%aboutGarden'
    else if bodyContainsEither(body, gargoyle_triggers)
        response = '%aboutGargoyle'
    else
        response = '%dontWant'

    cb null, {response, context}

generateResponse = ({response, parsed, context}, cb) ->

    body = nalgene.generate grammar, null, response
    cb null, {body, response, parsed, context}

module.exports = {
    grammar
    parseMessage
    generateResponse
}
