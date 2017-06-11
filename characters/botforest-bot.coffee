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
        @parseMessage context, body, (err, {context, intent}) =>
            @applyIntentToContext context, intent, (err, context) =>
                @buildResponseFromIntent context, intent, cb

module.exports = BotforestBot
