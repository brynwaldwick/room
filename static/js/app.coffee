React = require 'react'
ReactDOM = require 'react-dom'
reactStringReplace = require 'react-string-replace'
{ValidatedForm} = require 'validated-form'
FeedItems = require './feed-items'

dispatcher = require './dispatcher'

App = React.createClass

    render: ->
        <div className='app'>
            <div className='nav'>
                <i className='fa fa-bars' />
            </div>
            <div className='content'>
                <Messages />
                <MessagePublisher />
            </div>
        </div>

Messages = React.createClass

    getInitialState: ->
        messages: []

    componentDidMount: ->
        @messages$ = dispatcher.findMessages {client_key: window.client_key}, (err, messages) =>
            @setState {messages}, =>
                @fixScroll()
        # @messages$.onValue @foundMessages
        @newMessages$ = dispatcher.newMessages$()
        @newMessages$.onValue @newMessage

    foundMessages: (messages) ->
        @setState {messages: messages.reverse()}, =>
            @fixScroll()

    newMessage: (message) ->
        _messages = @state.messages
        _messages.push message
        @setState {messages: _messages}, =>
            @fixScroll()

    fixScroll: ->
        $feed = document.getElementById('messages')
        $messages = @refs.messages
        $messages.scrollTop = $messages.scrollHeight - $messages.clientHeight

    render: ->
        <div className='events-feed'>
            <div className='messages' id='messages' ref='messages'>
                <div className='chapter-header'>
                    <h2>Chapter {level.index}</h2>
                    <h4>{level.name}</h4>
                </div>
                {@state.messages.map @renderMessage}
            </div>
        </div>

    sendMessage: (body) -> =>
        dispatcher.intents$.emit {type: 'message', body}

    populateInput: (body) -> =>
        dispatcher.intents$.emit {type: 'talk-to', body}

    renderMessage: (message, i) ->
        if !(message.from in ['user', 'Room', 'room'])
            from_class = "from-character"
        {kind} = message

        <div key=message._id className="message #{from_class}">
            <div className="from">{message.from}</div>
            <div className='body'>
                {message.body.split('\n').map (line, li) =>
                    i = 0
                    <p key={'li_' + li}>
                        {replaced = reactStringReplace line, /(#\w+)/g, (match, mi) =>
                            value = match.replace("#", "").replace('_'," ")
                            to_send = "inspect " + value
                            <a key={'ma_men_' + li + '_' + mi} onClick={@sendMessage(to_send)}>{value}</a>
                        replaced = reactStringReplace replaced, /(~\w+)/g, (match, mi) =>
                            to_send = "goto " + match.replace "~", ""
                            <a key={'ma_dir_' + li + '_' + i++} onClick={@sendMessage(to_send)}>{match.replace "~", ""}</a>
                        replaced = reactStringReplace replaced, /(@\w+)/g, (match, mi) =>
                            target = match.replace("@", "").replace('_'," ")
                            value = "@" + target
                            <a key={'ma_talk_to_' + li + '_' + mi} onClick={@populateInput(value)}>{value}</a>
                        replaced
                        }
                    </p>}
            </div>
            {if message.form#kind == 'combo'
                <FeedItems.DoorCombo message=message sendMessage=@sendMessage />
            }
        </div>

MessagePublisher = React.createClass
    
    getInitialState: ->
        value: ''

    changeValue: (e) ->
        value = e.target.value
        @setState {value}

    componentDidMount: ->
        dispatcher.intents$.onValue (i) =>
            if i.type == 'message'
                @setState value: i.body, =>
                    @sendMessage()

            else if i.type == 'talk-to'
                @setState value: i.body + ' ', =>
                    @refs.publisher.focus()

    onKeyPress: (e) ->
        if e.which == 13
            @sendMessage()

    sendMessage: ->
        body = @state.value
        new_message = {
            body
            from: 'user'
            client_key: window.client_key
        }
        dispatcher.sendMessage new_message, (resp) =>
            if matched = body.match /\@([\w]*)/g
                @setState value: matched[0] + ' '
            else
                @setState value: ''

    render: ->
        <div className='message-publisher'>
            <input
                ref='publisher'
                placeholder='Send a message to Room'
                value=@state.value
                onChange=@changeValue
                onKeyPress=@onKeyPress
            />
        </div>

ReactDOM.render <App />, document.getElementById 'app'
