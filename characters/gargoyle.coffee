async = require 'async'

intents = {
    'hi':
        trigger_words: [' hi', 'hello', ' hey']

    'girlPrettyResponse':
        trigger_words: [
            '$and',
            ['girl', 'she', 'her', 'mary'],
            ['beautiful', 'pretty', 'nice', 'like', 'great', 'amazing', 'kind']
        ]
        commands: [
            cmd: "incMood"
            args: 0.25
        ]

    'girlUglyResponse':
        trigger_words: [
            '$and',
            ['girl', 'she', 'her', 'mary'],
            ['ugly', 'hate', 'dumb', 'annoying', 'bossy', 'stupid', 'bitch', 'whore', 'suck', 'cunt']
        ]
        commands: [
            cmd: "incMood"
            args: -0.25
        ]

    'curseResponse':
        trigger_words: ['']
        commands: [
            cmd: "incMood"
            args: -0.15
        ]

    'requestCombo':
        trigger_words: ['combo', 'combination', 'unlock', 'door', 'far door']
}


grammar = '''

    %hi
        Hello, mate
        Oy
        Hi there

    %dontunderstand
        I don't understand ye, mate
        Talk to me about Mary
        What d'ye mean?

    %becameNice
        Thanks for saying that friend. I'm startin to warm up to ye'

    %comboPromptNoHelp
        I am ornery. I don't want to tell you.

    %comboPromptNegative
        Why should I tell y'? Yer bein an ass.
        I could be more forthcoming were I a bit happier.

    %comboPromptPositive
        It's 1-2-3-4-5
        Use the combo 1-2-3-4-5

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

{bodyContainsEither, bodyContains} = require './helpers'

hello_triggers = [' hi', 'hello', ' hey']
girl_triggers = ['girl', 'she', 'her', 'mary']
curse_triggers = ['fuck', 'shit', 'bitch', 'asshole']
pretty_triggers = ['beautiful', 'pretty', 'nice', 'like', 'great', 'amazing', 'kind']
ugly_triggers = ['ugly', 'hate', 'dumb', 'annoying', 'bossy', 'stupid', 'bitch', 'whore', 'suck', 'cunt']
door_triggers = ['combo', 'combination', 'unlock', 'door', 'far door']

parseMessage = (context, body, cb) ->
    {location, topic, mood} = context
    if bodyContainsEither(body, girl_triggers) && bodyContainsEither(body, ugly_triggers)
        intent = '%girlUglyResponse'
        context.mood -= 0.25
    else if bodyContainsEither(body, girl_triggers) && bodyContainsEither(body, pretty_triggers)
        intent = '%girlPrettyResponse'
        context.mood += 0.25
    else if bodyContainsEither(body, curse_triggers)
        intent = '%curseResponse'
        context.mood -= 0.15
    else if bodyContainsEither(body, hello_triggers)
        intent = '%hi'
    else if bodyContainsEither(body, door_triggers)
        intent = '%requestCombo'
    cb null, {intent, context}

buildResponseFromIntent = (context, intent, cb) ->
    response_template = context.response_template_type || intent

    if response_template == '%requestCombo'
        if context.mood > 0.8
            response_template = '%comboPromptPositive'
        else if context.mood < 0.5
            response_template = '%comboPromptNegative'
        else
            response_template = '%comboPromptNoHelp'

    if context.mood < 0.2
        response_template = '%flipOut'
        context.trigger = "gargoyle:fall"

    else if (response_template in ['%girlPrettyResponse']) && (context.mood > 0.8)
        response_template = '%becameNice'

    else if !response_template?
        template_context = {}
        response_template = '%dontunderstand'

    body = nalgene.generate grammar, null, response_template
    cb null, {body, intent, context}

# Gargoyle Service
# -----------------------------------------------------------------------------

methods = {
    incMood: (context, delta, cb) ->
        context.gargoyle.mood += delta
        response = {}
        cb null, {context}
    setMood: (context, new_mood, cb) ->
        context.gargoyle.mood = new_mood
        cb null, {context}
}

# TODO: BotforestBot class, ({intents, commands}) ->
# -----------------------------------------------------------------------------

interpretCommand = (context, {cmd, args}, cb) ->
    methods[cmd] context, args..., cb

applyIntentToContext = (context, intent, cb) ->
    # 1) Apply context update
    context_update = intent?.context_update || {}
    Object.assign {}, context, context_update

    # 2) Run commands
    commands = intent?.commands || []
    async.series (commands.map (command) ->
        return (cb) ->
            interpretCommand context, command, cb
        ), (err, done) ->
            console.log "Any mutations to context?", context
            console.log "Any context for response template?", context.template_context
            cb err, context


handleMessage = (context, body, cb) ->
    parseMessage context, body, (err, {context, intent}) ->
        applyIntentToContext context, intent, (err, context) ->
            buildResponseFromIntent context, intent, cb

module.exports = {
    handleMessage
    grammar
    parseMessage
    buildResponseFromIntent
}

# Other dialog ideas

# ask_about: #(this is like inspect but by talking to another person)
#     picture_on_wall: "This is my favorite piece. Far better than that shit they're making endlessly with those colored pens in there. The emotion of this painting: The meaning, or the lack thereof, or the search for that meaning, is everything. To wit - why does King Arthur do what he does? Are we to know? Is there any logical reason to consider the answer? Is the fact that I'm here talking to you right now about the picture the only reason for his existence?"
#     dragon: "He was a good guy but he had some kind of temper."
#     king_arthur: "Not really sure."
#     picture_in_hand: "That's my girlfriend. Don't ask about it."
#     butler: "I'm not convinced the guy exists to be frank... if it weren't for you here today I'd doubt it completely."
#     girl: "I would tell you not to go near her but you've just come from there."
# trigger_good_somehow: "Thanks for the chat. I think this could really be a breakthrough for me. I feel lighter already, please hold me for a moment."
# pick_up: "The combo to that door is 8-8-5-3-1."
# be_nice: "He says thanks, some generative nice thing in a certain conversational style"
    # tell that gardener to keep his potty mouth away if you ever make it out there
# parser (pass in body and topic)
    # girl in the room is ugly vs. girl in the painting is ugly