React = require 'react'

Menu = React.createClass

    getInitialState: ->
        open_overlay: null

    openOverlay: (open_overlay) ->
        @setState {open_overlay}

    render: ->
        <div className='menu'>
            {if @state.open_overlay
                <div className='menu-overlay'>
                    <div className='overlay-backdrop' onClick={@openOverlay.bind(null,null)} />
                    <div className='overlay-content'>
                        <MenuOverlay topic=@state.open_overlay />
                        <a className='close' onClick={@openOverlay.bind(null,null)} >close</a>
                    </div>
                </div>

            }
            <div className='menu-links'>
                <a onClick={@openOverlay.bind(null,'howtoplay')} >How to play</a>
                <a onClick={@openOverlay.bind(null,'signup')}>Sign up</a>
                <a onClick={@openOverlay.bind(null,'share')}>Share with friends</a>
            </div>
            <div className='menu-footer'>
                <a onClick={@openOverlay.bind(null,'howitworks')}>How it works</a>
                <a onClick={@openOverlay.bind(null,'abouttheauthor')}>About the author</a>
                <a href="http://donotenter.io" className='publisher-note'>c2177 Furnished by Publisher Guild Productions</a>
            </div>
        </div>

MenuOverlay = React.createClass

    render: ->
        {topic} = @props
        if topic == 'howtoplay'
            <div className='menu-overlay-content how-to-play'>
                <div>(the <span className='emphasis' title='click them'>black links</span> are just for you)</div>
                <div><span className='emphasis' title='inspect table'>inspect</span> things</div>
                <div><span className='emphasis' title='go to the patio'>go</span> somewhere</div>
                <div><span className='emphasis' title='take the pan'>take</span> things</div>
                <div><span className='emphasis' title='@tom hi there tom'>@character</span> to talk to them</div>
                <div><span className='emphasis' title='inventory'>inventory</span></div>
                <div><span className='emphasis' title='can your inventory be of use?'>you may need to type other important commands, so try stuff!</span></div>
            </div>
        else if topic == 'signup'
            <div className='menu-overlay-content signup'>
                Signup Form
            </div>

        else if topic == 'share'
            <div className='menu-overlay-content sharewithfriends'>
                <div><a>On Reddit</a></div>
                <div><a>On Twitter</a></div>
                <div><a>On Facebook</a></div>
            </div>
                # <div><a>Copy Link</a></div>

        else if topic == 'abouttheauthor'
            <div className='menu-overlay-content' >
                <p>Bryn Waldwick is a Partner at <a href='https://prontotype.us'>Prontotype</a>, where he helps build scalable businesses with great computer code.</p>
                <p>He likes to research "Blockchain" and how to build things that are easy for users and developers.</p>
                <p>He dreams about new platforms that make practicing art meaningful and valuable.</p>
                <div className='social-links'>
                    <a href='https://github.com/brynwaldwick' >
                        <i className='fa fa-github' />
                    </a>
                    <a href='https://twitter.com/brynwaldwick' >
                        <i className='fa fa-twitter' />
                    </a>
                    <a href='https://www.linkedin.com/in/brynwaldwick/' >
                        <i className='fa fa-linkedin' />
                    </a>
                </div>
            </div>

        else if topic == 'howitworks'
            <div className='menu-overlay-content howitworks'>
                <p>Room is a text-only adventure game with many levels. The levels house a variety of colorful characters.</p>
                <p>The levels are built with a <a href='https://github.com/brynwaldwick/room'>narration engine</a> that makes creating customized adventure experiences very easy. The characters are dialog bots who get better with age... and they inhabit different levels with the same internals.</p>
                <p>Thus, no two adventures can be the same.</p>
            </div>

module.exports = Menu