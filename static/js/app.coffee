React = require 'react'
ReactDOM = require 'react-dom'
reactStringReplace = require 'react-string-replace'

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
                    <h2>Chapter 1</h2>
                    <h4>Room</h4>
                </div>
                {@state.messages.map @renderMessage}
            </div>
        </div>

    sendMessage: (body) -> =>
        dispatcher.intents$.emit {type: 'message', body}

    renderMessage: (message, i) ->
        <div key=message._id className='message'>
            <div className='from'>{message.from}</div>
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
                        replaced
                        }
                    </p>}
            </div>
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

    onKeyPress: (e) ->
        if e.which == 13
            @sendMessage()

    sendMessage: ->
        new_message = {
            body: @state.value
            from: 'user'
            client_key: window.client_key
        }
        dispatcher.sendMessage new_message, (resp) =>
            @setState value: ''

    render: ->
        <div className='message-publisher'>
            <input placeholder='Send a message to Room' value=@state.value onChange=@changeValue onKeyPress=@onKeyPress />
        </div>

ReactDOM.render <App />, document.getElementById 'app'
