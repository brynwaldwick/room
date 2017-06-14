React = require 'react'
{ValidatedForm} = require 'validated-form'

DoorComboLock = React.createClass
    submitForm: (values) ->
        if @props.sendMessage?
            combo = values.combo.replace(/-/g,'').replace(/,/g,'').replace(/\s+/g,'')
            @sendMessage "unlock far door #{combo}"

    sendMessage: (body) ->
        @props.sendMessage(body)()

    render: ->
        <div className='form'>
            <ValidatedForm fields=@props.message.form onSubmit=@submitForm />
        </div>

renderers = {
    "DoorCombo": DoorComboLock
}
# TODO:
# module.exports = CustomFeed(renderers)
module.exports = renderers