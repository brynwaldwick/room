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
            <h1>Room</h1>
            <div className='description'>A conversation adventure.</div>
            <div className='menu-links'>
                <a >
                    Table Of Contents
                </a>
                <div><a href='/levels/1'>Chapter 1</a></div>
                <div><a href='/levels/2'>Chapter 2</a></div>
                <div><a href='/levels/3'>Chapter 3</a></div>
                <div><a href='/levels/4'>Chapter 4</a></div>
                <div><a href='/levels/5'>Chapter 5</a></div>
                <div><a href='/levels/6'>Chapter 6</a></div>
            </div>
            <div className='menu-footer'>
                <a onClick={@openOverlay.bind(null,'howtoplay')} >How to play</a>
                <a onClick={@openOverlay.bind(null,'share')}>Share with friends</a>
                <a onClick={@openOverlay.bind(null,'abouttheauthor')}>About the author</a>
                <a onClick={@openOverlay.bind(null,'howitworks')}>How it works</a>
                <a onClick={@openOverlay.bind(null,'dedicated')}>@</a>
                <a href="http://donotenter.io" className='publisher-note'>c2177 Furnished by Publisher Guild Productions</a>
            </div>
        </div>
                # <a onClick={@openOverlay.bind(null,'signup')}>Sign up</a>

MenuOverlay = React.createClass

    render: ->
        {topic} = @props
        if topic == 'howtoplay'
            <div className='menu-overlay-content how-to-play'>
                <div>(the <span className='emphasis' title='click them'>black links</span> in the story are just for you)</div>
                <div><span className='emphasis' title='inspect table'>inspect</span> things</div>
                <div><span className='emphasis' title='go to the patio'>go</span> somewhere</div>
                <div><span className='emphasis' title='take the pan'>take</span> things</div>
                <div><span className='emphasis' title='@tom hi there tom'>@character</span> to talk to them</div>
                <div><span className='emphasis' title='inventory'>inventory</span> lists the things you've taken</div>
                <div><span className='emphasis' title='can your inventory be of use?'>you may need to type other important commands, so try stuff!</span></div>
            </div>

        else if topic == 'signup'
            <div className='menu-overlay-content signup'>
                Signup Form
            </div>

        else if topic == 'toc'
            <div className='menu-overlay-content toc'>
                <div><a href='/levels/1'>Chapter 1</a></div>
                <div><a href='/levels/2'>Chapter 2</a></div>
            </div>

        else if topic == 'share'
            url = "http://entertheroom.io"
            text = encodeURIComponent("I just took an adventure through Room")

            reddit_link = "http://www.reddit.com/submit?url=#{url}&title=#{text}"
            twitter_link = "https://twitter.com/intent/tweet/?url=#{url}&text=#{text}"
            facebook_link = "https://www.facebook.com/sharer/sharer.php?u=#{url}"

            <div className='menu-overlay-content sharewithfriends'>
                <div><a href=reddit_link target='_newtab' >On Reddit</a></div>
                <div><a href=twitter_link target='_newtab' >On Twitter</a></div>
                <div><a href=facebook_link target='_newtab' >On Facebook</a></div>
            </div>
                # <div><a>Copy Link</a></div>

        else if topic == 'abouttheauthor'
            <div className='abouttheauthor menu-overlay-content' >
                <div className='author-portrait'>
                    <img src='http://prontotype.us/images/team/bryn.jpg' />
                </div>
                <p>Bryn Waldwick is a Partner at <a href='https://prontotype.us'>Prontotype</a>, where he helps build scalable businesses with great computer code.</p>
                <p>He likes to research "Blockchain" and how to build things that are easy for users and developers.</p>
                <p>He dreams about new ways to make creativity more meaningful and more valuable.</p>
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
                <p>Room is a text-only adventure game with many levels. It houses a variety of colorful characters.</p>
                <p>The levels are built with a <a href='https://github.com/brynwaldwick/room'>narration engine</a> that makes creating customized adventure experiences very easy. The characters are dialog bots who get better with age... and they inhabit different levels with the same internals.</p>
                <p>Thus, no two adventures will ever be the same.</p>
            </div>
        else if topic == 'dedicated'
            <div className='menu-overlay-content dedicated'>
                <p>More toasts for the people that have always been there & the good yet to be grown.</p>
            </div>

module.exports = Menu