async = require 'async'

BotforestBot = class BotforestBot

    constructor: (@parseMessage, @buildResponseFromIntent, @methods) ->
        return @

    interpretCommand: (context, {cmd, args}, cb) ->
        @methods[cmd] context, args..., cb

    applyIntentToContext: (context, intent, cb) ->
        # 1) Apply context update
        context_update = intent?.context_update || {}
        Object.assign {}, context, context_update

        # 2) Run commands
        commands = intent?.commands || []
        async.series (commands.map (command) =>
            return (cb) =>
                @interpretCommand context, command, cb
            ), (err, done) ->
                # console.log "Any mutations to context?", context
                # console.log "Any context for response template?", context.template_context
                # console.log "Any setting of the response template type??", context.response_template_type
                cb err, context

    handleMessage: (context, body, cb) ->
        @log 'incoming-message', {body, context}
        @parseMessage context, body, (err, {context, intent}) =>
            @log 'parsed-intent', {body, context}
            @applyIntentToContext context, intent, (err, context) =>
                @log 'commands-complete', {context}
                @buildResponseFromIntent context, intent, (err, response) =>
                    {body, intent, context, parsed} = response
                    @log 'response', response
                    cb err, response

    log: (type, event) ->
        if err?
            console.log 'ERROR:', err
        console.log 'BotforestBot.log', type, event
        # TODO: decorate with information about bot & context
        # BotforestService 'createEvent', event, (err, botforest_response) ->
        #     console.log 'response', err, botforest_response

module.exports = BotforestBot
