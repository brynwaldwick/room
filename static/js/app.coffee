React = require 'react'
ReactDOM = require 'react-dom'
reactStringReplace = require 'react-string-replace'
{ValidatedForm} = require 'validated-form'
FeedItems = require './feed-items'
Menu = require './menu'

dispatcher = require './dispatcher'

levelIndexFromClientKey = (client_key) ->
    if client_key?.split(':')[0] == 'levels'
        return Number(client_key?.split(':')[1])
    else
        return 1

App = React.createClass

    getInitialState: ->
        menu: false
        how_to_open: false
        overlay: null
        open_overlay: null

    openOverlay: (open_overlay) ->
        @setState {open_overlay}

    toggleMenu: ->
        @setState menu: !@state.menu

    toggleHowTo: ->
        @setState how_to_open: !@state.how_to_open

    sendMessage: (body) -> =>
        dispatcher.intents$.emit {type: 'message', body}

    render: ->
        <div className='app'>
            {if @state.menu
                <Menu />
            else if @state.how_to_open
                <div className='menu-overlay'>
                    <div className='overlay-backdrop' onClick={@toggleHowTo} />
                    <div className='overlay-content'>
                        <div className='menu-overlay-content how-to-play'>
                            <div>(the <span className='emphasis' title='click them'>black links</span> in the story are just for you)</div>
                            <div><span className='emphasis' title='inspect table'>inspect</span> things</div>
                            <div><span className='emphasis' title='go to the patio'>go</span> somewhere</div>
                            <div><span className='emphasis' title='take the pan'>take</span> things</div>
                            <div><span className='emphasis' title='@tom hi there tom'>@character</span> to talk to them</div>
                            <div><span className='emphasis' title='inventory'>inventory</span> lists the things you've taken</div>
                            <div><span className='emphasis' title='can your inventory be of use?'>you may need to type other important commands, so try stuff!</span></div>
                        </div>
                        <a className='close' onClick={@toggleHowTo} >close</a>
                    </div>
                </div>            
            }
            <div className='nav'>
                <i className='fa fa-suitcase' onClick={@sendMessage('inventory')} />
                <i className='fa fa-eye' onClick={@sendMessage('look around')} />
                <i className='fa fa-question-circle-o' onClick=@toggleHowTo />
                <i className='fa fa-bars' onClick=@toggleMenu />
            </div>
            <div className='content'>
                <Messages />
                <MessagePublisher />
            </div>
        </div>


HomePage = React.createClass

    # h1 Room
    # .description A text-only conversational adventure game.
    # .menu
    #     .menu-link Table of Contents
    #         .chapter Chapter 1
    #         .chapter Chapter 2
    #     .menu-bottom
    #         .menu-link How to play

Messages = React.createClass

    getInitialState: ->
        messages: []

    componentDidMount: ->
        @messages$ = dispatcher.findMessages {client_key: window.client_key}, (err, messages) =>
            console.log 'found the messages', err, messages
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

    doFunction: (name) -> =>
        switch name
            when 'Restart'
                dispatcher.Restart(window.client_key).onValue (v) ->
                    window.location.reload()
            when 'Next'
                level_index = levelIndexFromClientKey(window.client_key) + 1
                window.location = "/levels/#{level_index}"
            else
                dispatcher[name]?()

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
                            to_send = "go to the " + match.replace "~", ""
                            <a key={'ma_dir_' + li + '_' + i++} onClick={@sendMessage(to_send)}>{match.replace "~", ""}</a>
                        replaced = reactStringReplace replaced, /(@\w+)/g, (match, mi) =>
                            target = match.replace("@", "").replace('_'," ")
                            value = "@" + target
                            <a key={'ma_talk_to_' + li + '_' + mi} onClick={@populateInput(value)}>{value}</a>
                        replaced = reactStringReplace replaced, /(>\w+)/g, (match, mi) =>
                            value = match.replace(">", "").replace('_'," ")
                            <a key={'ma_do' + li + '_' + mi} onClick={@doFunction(value)}>{value}</a>
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
