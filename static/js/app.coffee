React = require 'react'
ReactDOM = require 'react-dom'

dispatcher = require './dispatcher'

App = React.createClass

    render: ->
        <div className='app'>
            <div className='nav'>
                <h1>Room</h1>
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
        @messages$ = dispatcher.findMessages$ {}
        @messages$.onValue @foundMessages

        @newMessages$ = dispatcher.newMessages$()
        @newMessages$.onValue @newMessage

    foundMessages: (messages) ->
        @setState {messages: messages.reverse()}, =>
            @fixScroll()

    newMessage: (message) ->
        console.log 'i got a new message', message.body
        _messages = @state.messages
        _messages.push message
        @setState {messages: _messages}, =>
            @fixScroll()

    fixScroll: ->
        $feed = document.getElementById('messages')
        console.log $feed
        console.log $feed.scrollTop
        console.log $feed.scrollHeight
        $messages = @refs.messages
        console.log $messages
        $messages.scrollTop = $messages.scrollHeight - $messages.clientHeight

        # $feed.scrollTop = $feed.scrollHeight

    render: ->
        <div className='events-feed'>
            <div className='messages' id='messages' ref='messages'>
                {@state.messages.map @renderMessage}
            </div>
        </div>

    renderMessage: (message, i) ->
        <div key=message._id className='message'>
            <div className='from'>{message.from}</div>
            <div className='body'>{message.body}</div>
        </div>

MessagePublisher = React.createClass
    
    getInitialState: ->
        value: ''

    changeValue: (e) ->
        value = e.target.value
        @setState {value}

    onKeyPress: (e) ->
        if e.which == 13
            @sendMessage()

    sendMessage: ->
        new_message = {
            body: @state.value
            from: 'user'
        }
        dispatcher.sendMessage new_message, (resp) =>
            @setState value: ''

    render: ->
        <div className='message-publisher'>
            <input placeholder='Send a message to Room' value=@state.value onChange=@changeValue onKeyPress=@onKeyPress />
        </div>

ReactDOM.render <App />, document.getElementById 'app'
