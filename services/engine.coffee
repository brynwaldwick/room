somata = require 'somata'

client = new somata.Client()

DataService = client.remote.bind client, 'room:data'

levelIndexFromClientKey = (client_key) ->
    if client_key?.split(':')[0] == 'levels'
        return client_key?.split(':')[1]
    else
        return 1

# this service subscribes to the data service and makes any resulting
# actions as a function of the changing contexts, etc...

client.subscribe "room:data", "messages:created", (new_message) ->
    console.log 'message made', new_message
    level = levelIndexFromClientKey new_message.client_key
    switch new_context.level
        when 2
            if new_message.from == 'aviana'
                # ...

client.subscribe "room:data", "contexts:updated", (r) ->
    console.log 'context updated', r

client.subscribe "room:data", "contexts:new_context", (context_update, new_context) ->
    console.log 'context updated', context_update, new_context
    switch new_context.level
        when 1
            if context_update?.gargoyle?.mood < 0.2
                console.log 'the gargoyle should be flipping out'

            # If the door gets unlocked, narrate it swinging open
            # Make the gardener react to steer you into the eggs very indirectly.

        when 2
            # if aviana talks, president says something based on what she says
            # (pipe to botforest as chat does)
            # else if response_message.from == 'aviana'
            #     _context.channel = response_message.channel || response_message.client_key
            #     President.handleMessage _context, body, (err, response) ->
            #         if response.body?
            #             createAndPublishMessage {
            #                 body: response.body
            #                 from: 'president'
            #                 client_key: new_message.client_key
            #             }, (err, message_response) ->
            #                 console.log 'hello', err, message_response

            # If president gets triggered red or green, do something and end the level.

        when 3
            # When you convince Tim or Sally to go into the antechamber, Mr. Wallace follows
            # When Mr. Wallace goes into antechamber, set a trigger for him to come out in 45
            # seconds.

        when 4
            # 

        when 5
            # 

        when 6
            # When the chicken gets done talking, she walks away
            # When the hunchback gets done talking, the figure comes from the forest
            # The figure stays by the ocean for five minutes.

engine = new somata.Service "room:engine", {}




