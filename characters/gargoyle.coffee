
grammar = '''

    %dontunderstand
        I don't understand ye, mate
        Talk to me about Mary
        What d'ye mean?

    %becomeNice
        Thanks for saying that friend. I'm startin to warm up to ye'

    %comboPromptNegative
        Why should I tell y'? Yer bein an ass.
        I could be more forthcoming were I a bit happier.

    %comboPromptPositive
        It's 1-2-3-4-5

    %interpretPainting
        I dunno. What d' you think?

    %girlPrettyResponse
        I've oft thought the same.
        Can't help but agree mate. If my old stone bones could sing...

    %girlUglyResponse
        That's disrespectful mate. Watch yerself.
        Don't say that about her.
        Watch yerself.

    %curseResponse
        Don't curse mate.
        Please... don't curse mate.
        I'll wash yer mouth out!

    %flipOut
        Ye' right cunt!
        Ye' damn scab!
        Get out!
'''

nalgene = require 'nalgene'
grammar = nalgene.parse grammar

girl_triggers = ['girl', 'she', 'her']
curse_triggers = ['fuck', 'shit', 'bitch', 'asshole']
pretty_triggers = ['beautiful', 'pretty', 'nice', 'like']
ugly_triggers = ['ugly', 'hate', 'stupid', 'bitch', 'whore', 'cunt']
door_triggers = ['combo', 'combination', 'unlock', 'door', 'far door']

parseMessage = (context, body, cb) ->
    {location, topic, mood} = context
    bodyContains = (str) ->
        body.indexOf(str) > -1
    bodyContainsEither = (arr) ->
        words_contained = arr.filter (w) ->
            body.indexOf(w) > -1
        return words_contained?.length

    if bodyContainsEither(girl_triggers) && bodyContainsEither(ugly_triggers)
        response = '%girlUglyResponse'
        context.mood -= 0.25
    else if bodyContainsEither(girl_triggers) && bodyContainsEither(pretty_triggers)
        response = '%girlPrettyResponse'
        context.mood += 0.25
    else if bodyContainsEither(curse_triggers)
        response = '%curseResponse'
        context.mood -= 0.15

    else if bodyContainsEither(door_triggers)
        if context.mood > 0.8
            response = '%comboPromptPositive'
        else
            response = '%comboPromptNegative'

    cb null, {response, context}

generateResponse = ({response, parsed, context}, cb) ->
    if context.mood < 0.2
        entry = '%flipOut'
    else if (response !='%comboPromptPositive') && (context.mood > 0.8)
        entry = '%becomeNice'
    else if !response?
        template_context = {}
        entry = '%dontunderstand'
    else
        entry = response

    body = nalgene.generate grammar, null, entry
    cb null, {body, response, parsed, context}

# ...
# change mood of gargoyle in each client's context
# if we're talking about the girl then get mad if ugly, happy if pretty
# get mad if you curse
# (this is a non-narrator response)
# if it is over a threshold, then trigger a certain response (wobble or give combo)
# garden, outside
    # tell that gardener to keep his potty mouth away if you ever make it out there
# paintingInterpretation
    # what do you think it means?
# parser (pass in body and topic)
    # girl in the room is ugly vs. girl in the painting is ugly
# + ideally configure the outcomes by level eventually

module.exports = {
    grammar
    parseMessage
    generateResponse
}
