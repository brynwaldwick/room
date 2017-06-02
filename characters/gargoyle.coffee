
grammar = '''

    %comboPromptNegative
        Why should I tell y'? Yer bein an ass.
        I could be more forthcoming were I a bit happier.

    %comboPromptPositive
        Will

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

parseMessage = ({context, body}, cb) ->
    cb null

# ...
# change mood of gargoyle in each client's context
# if we're talking about the girl then get mad if ugly, happy if pretty
# get mad if you curse
# (this is a non-narrator response)
# if it is over a threshold, then trigger a certain response (wobble or give combo)
# curseResponse
# girlPositive
# girlNegative
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
}
