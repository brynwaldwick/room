




async = require 'async'
BotforestBot = require './botforest-bot'
nalgene = require 'nalgene'

# intents = {
#     'hi':
#         trigger_words: [' hi', 'hello', ' hey']

#     'girlPrettyResponse':
#         trigger_words: [
#             '$and',
#             ['girl', 'she', 'her', 'mary'],
#             ['beautiful', 'pretty', 'nice', 'like', 'great', 'amazing', 'kind']
#         ]
#         commands: [
#             cmd: "incMood"
#             args: 0.25
#         ]

#     'girlUglyResponse':
#         trigger_words: [
#             '$and',
#             ['girl', 'she', 'her', 'mary'],
#             ['ugly', 'hate', 'dumb', 'annoying', 'bossy', 'stupid', 'bitch', 'whore', 'suck', 'cunt']
#         ]
#         commands: [
#             cmd: "incMood"
#             args: -0.25
#         ]

#     'curseResponse':
#         trigger_words: ['']
#         commands: [
#             cmd: "incMood"
#             args: -0.15
#         ]

#     'requestCombo':
#         trigger_words: ['combo', 'combination', 'unlock', 'door', 'far door']
# }

balances = {
}


grammar = '''
    %hi
        Hello again! Thanks for banking with us.
        Hello.
        Hi there
        Good afternoon. What can I do for you?

    %help
        Type deposit to make a deposit. Type withdraw to withdraw. I can also help you with a safety deposit box.

    %promo
        While I have you, would you like to sign up for a fractal ownership account? One account this year means ten accounts next year, the terms cannot be beaten.
        Do you have a Buyer Benefits Number yet?
        Have you heard about our Grocery, Gas, and Goody Bag promotion?

    %welcome
        Welcome to Extempory Bank, how can I help you?
        Hello again, how long has it been?
        Thanks for banking with us. What can I do for you?

    %deposit_disambiguation
        How much would you like to deposit?

    %deposit_confirmation
        Thanks very much. I am going to deposit these tokens to your account. Is that correct?
        Would you like to deposit this much?

    %transaction_complete
        Ok that is sorted. Thanks again for your business. Is there anything else I can help you with? Would you like to open a safety deposit box?

    %deposit_box_disambiguation
        And what is the username on that box?

    %open_deposit_box
        Ok, please follow me through the impending Hallway.
        Thank you very much, follow me through that Hallway.

    %withdraw_disambiguation
        How much would you like to withdraw?

    %withdraw_confirmation
        Alright. I'll withdraw this many tokens. Is that correct?
        I am about to withdraw this many tokens. Shall I proceed?

    %balance_inquiry
        I'll check on that for you.

    %do_deposit
        Excellent. Your account has been credited. Is there anything else I can help you with today?

    %new_account
        Very good! Can I please have a username to put on your account?

    %insufficient_balance
        I'm sorry, but you don't have enough tokens in your account for that. Do you have an account under a different username?
        Insufficient balance.
        It looks like you don't have a balance with us. Can I help you deposit some tokens? Would you like to open a safety deposit box?

    %not_enough_tokens
        It looks like you don't have enough tokens to deposit that much.

    %failure
        Failure. There was an error accessing that box. It likely does not exist.
        Sorry, looks like that box doesn't exist.
        Error. No box.

    %dontunderstand
        I'm sorry but I just don't understand. Perhaps you'd like to make a deposit or withdraw some tokens? I can also help you use a safety deposit box.
'''

grammar = nalgene.parse grammar

{bodyContainsEither, bodyContains} = require './helpers'

hello_triggers = [' hi', 'hello', ' hey']
help_triggers = ['help', 'what can you do', 'services', 'manual', 'assistance']
deposit_box_triggers = ['deposit box']
deposit_triggers = ['deposit', 'add']
withdraw_triggers = ['give me', 'withdraw', 'take out', 'cash']
balance_triggers = ['balance', 'how much', 'how many']
yes_triggers = ['yes', 'yup', 'mmhmm', 'yup', 'yes please', 'yeah', 'yah']
open_account_triggers = ['open an account', 'new account', 'make an account']

interrogation_triggers = ['happened', 'grenade', 'bomb', 'kill', 'murder', 'who',
    'dead', 'why', 'room', 'murder', 'die']

parseValue = (body) ->
    not_value_words = ["tokens", "token"]
    value = body
    not_value_words.map (w) ->
        regEx = new RegExp(" " + w, "ig")
        value = value.replace regEx, ""
    anymention = body.match /\@([\w]*) /g
    value = value.replace(anymention, "")
    console.log 'the value', value
    return Number(value)

parseUsername = (body) ->
    value = body
    anymention = body.match /\@([\w]*) /g
    value = value.replace(anymention, "")
    return value

intents = {
    deposit_confirmation: {
        template: "%deposit_confirmation"
        context_update: {
            topic: 'deposit_confirmation'
        }
    }
    do_deposit: {
        template: "%transaction_complete"
        context_update: {
            topic: 'transaction_complete'
        }
        commands: [
            cmd: 'deposit'
            args: ["$context.data.deposit_amount"]
        ]
    }
    do_withdraw: {
        template: "%transaction_complete"
        context_update: {
            topic: 'transaction_complete'
        }
        commands: [
            cmd: 'withdraw'
            args: ["$context.data.withdraw_amount"]
        ]
    }
    balance_inquiry: {
        template: "%balance_inquiry"
        context_update: {
            topic: 'balance_inquiry'
        }
        commands: [
            cmd: 'checkBalance'
            args: ["$context.channel"]
        ]
    }
}

parseMessage = (context, body, cb) ->
    console.log 'here is your context', context
    {location, topic, mood} = context
    if context.topic == "deposit_disambiguation"
        context.data ||= {}
        context.data.deposit_amount = parseValue body
        if context.my_tokens < context.data?.deposit_amount
            intent = "%not_enough_tokens"
            context.topic = "room"
        else
            context.topic = "deposit_confirmation"
            intent = '%deposit_confirmation'

    if context.topic == "withdraw_disambiguation"
        context.data ||= {}
        context.data.withdraw_amount = parseValue body
        balances[context.channel] ||= 0
        if balances[context.channel] < context.data?.withdraw_amount
            intent = "%insufficient_balance"
            context.topic = "room"
        else
            context.topic = "withdraw_confirmation"
            intent = '%withdraw_confirmation'

    if context.topic == "deposit_box_disambiguation"
        context.data ||= {}
        context.data.deposit_box_username = parseUsername body
        if context.data.deposit_box_username in ['eve', 'mary']
            intent = "%open_deposit_box"
            context.topic = "%open_deposit_box"
        else
            intent = "%failure"
            context.topic = "%failure"

    else if (context.topic == "deposit_confirmation") && bodyContainsEither(body, yes_triggers)
        if context.data?.deposit_amount
            console.log 'its time to do the deposit', context
            intent = '%do_deposit'
            context.topic = "room"
        else
            context.topic = "deposit_disambiguation"
            intent = "%deposit_disambiguation"

    else if (context.topic == "withdraw_confirmation") && bodyContainsEither(body, yes_triggers)
        if context.data?.withdraw_amount
            intent = '%do_withdraw'
            context.topic = "room"
        else
            context.topic = "withdraw_disambiguation"
            intent = "%withdraw_disambiguation"

    else if bodyContainsEither(body, deposit_box_triggers)
        intent = '%deposit_box_disambiguation'
        context.topic = 'deposit_box_disambiguation'
    else if bodyContainsEither(body, deposit_triggers)
        intent = '%deposit_disambiguation'
        context.topic = 'deposit_disambiguation'
    else if bodyContainsEither(body, withdraw_triggers)
        intent = '%withdraw_disambiguation'
        context.topic = 'withdraw_disambiguation'
    else if bodyContainsEither(body, balance_triggers)
        intent = '%balance_inquiry'
    # else if bodyContainsEither(body, open_account_triggers)
    #     intent = '%new_account'
    #     context.topic = 'choose_username'

    else if bodyContainsEither(body, hello_triggers)
        intent = '%hi'
    else if bodyContainsEither(body, help_triggers)
        intent = '%help'
    if intent?
        intent = intents[intent.replace("%","")] || intent
    cb null, {intent, context}

buildResponseFromIntent = (context, intent, cb) ->
    response_template = context.response_template_type || intent?.template || intent

    if !response_template?
        template_context = {}
        response_template = '%dontunderstand'

    if response_template == "%open_deposit_box"
        context.trigger = "teller:open_hallway"

    if response_template == '%balance_inquiry'
        body = "Your balance is #{context.data.my_balance} tokens"
    else
        body = nalgene.generate grammar, null, response_template
    console.log 'and the topic is', context
    cb null, {body, intent, context}

# Gargoyle Service
# -----------------------------------------------------------------------------

methods = {
    deposit: (context, amount, cb) ->
        amount = context.data?.deposit_amount
        console.log 'im going to deposit', context, amount
        # if context.data?.amount_i_have < amount
        if !amount?
            context.response_template_type = "%deposit_disambiguation"
        else if context.my_tokens < amount
            context.response_template_type = "%not_enough_tokens"
        else
            console.log context.my_tokens, 'those are mine'
            console.log 'thats the amount', amount
            balances[context.channel] ||= 0
            balances[context.channel] += amount
            context.data?.my_tokens = context.my_tokens - amount
        # todo: deposit amount
        response = {}
        cb null, {context}
    withdraw: (context, amount, cb) ->
        amount = context.data.withdraw_amount
        if balances[context.channel] < amount
            context.response_template_type = "%insufficient_balance"
        else
            balances[context.channel] -= amount
            context.data?.my_tokens = context.my_tokens + amount

        # todo: withdraw amount
        # put amount into the person's inventory
        cb null, {context}

    checkBalance: (context, amount, cb) ->
        context.data ||= {}
        context.data.my_balance = balances[context.channel] || 0
        cb null, {context}
}

Tellerbot = new BotforestBot('teller', parseMessage, buildResponseFromIntent, methods, intents)
module.exports = Tellerbot
