BotforestBot = require './botforest-bot'
nalgene = require 'nalgene'

# rhymes
grammar = nalgene.parse '''

    %china
        Once the reds took over there was nothing left to write.

    %what_happened
        On 8am, Monday of that week, the last living journalist announced they were going to start fighting politics with art. 80% of humankind was dead within 9 days. On that 9th day they built a new world.
        What do you think ended the world? Something beyond us and ours and errors? All ears, Eros!
        Things kind of got out of hand...
        There was a monk who built a huge mechanical computer out of jade. But that got smashed with every other thing. What am I to do right now today to right that wrong?

    %president
        What do you want me to say? The man is a marvel. Give him an inch and he'll take a mile.
        I've been programmed to always watch him until destiny comes.
        Don't ask me to tell you what he's thinking. I heard they appointed a group of three women in charge of that.
        He was one of the first technophiles. A real ideas man. If it weren't for the ice around his neck I would have thought he was famous.
        The most common string in the universe was his global NOTE: "The brave step in when the fervor grows its tread."

    %call_phone
        I'm afraid I can't do that Jim...
        How am I supposed to do that?

    %call
        Which one?
        Who should I call?

    %call_president
        What is the phone number lol?
        Can you ask the gargoyle for the phone number? Of course I kid!

    %peace
        Peace was eventually made illegal 21 years after the Fed abolished the dollar. They issued a digital currency backed with milled barley. They baked vast loafs of fluffy bread using the stuff. It became less about the white and more about the green. At that point a super computer made out of children burned down the Earth.

    %fallback
        That is so confusing I almost don't know what to say.
        Sorry I don't understand...
        Maybe piecing together the chain of events will help us proceed.
        Not sure.
        ¿Que?
        Dinner time Sir. Seafoam eggs, young peas with mint creme and pickled red herring.
        Surely you can phrase it better than that.
        I wish you'd word it more clearly. I'm less read than you think.
        Can you write? Can you read?
        ?

    %what_you_think?
        What do you think we should do?
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
peace_triggers = ['ceasefire', 'peace']
happened_triggers = ['happened', 'affairs', 'war']
president_triggers = ['man', 'potus', 'president']
call_president = ['call the president']
call_phone = ['call the phone']

intents = {
    'china': {
        trigger_words: china_triggers
    }
    'president': {
        trigger_words: president_triggers
    }
    'what_happened': {
        trigger_words: happened_triggers
    }
}

methods = {}

{bodyContainsEither, bodyContains} = require './helpers'

parseMessage = (context, body, cb) ->
    {location, topic, mood} = context
    if bodyContainsEither(body, china_triggers)
        intent = 'china'
    else if bodyContainsEither(body, peace_triggers)
        intent = 'peace'
    else if bodyContainsEither(body, call_president)
        intent = 'call_president'
    else if bodyContainsEither(body, call_phone)
        intent = 'call_phone'
    else if bodyContainsEither(body, president_triggers)
        intent = 'president'
    else if bodyContainsEither(body, happened_triggers)
        intent = 'what_happened'
    else
        intent = 'fallback'

    cb null, {intent, context}

buildResponseFromIntent = (context, intent, cb) ->
    response_template = context.response_template_type || intent
    body = nalgene.generate grammar, null, "%#{response_template}"
    cb null, {body, intent, context}

Aviana = new BotforestBot('aviana', parseMessage, buildResponseFromIntent, methods)

module.exports = Aviana