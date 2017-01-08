config = require '../config'
orm = require('data-service/orm')(config.mongodb)

class Users extends orm.Collection
    @singular: 'user'
    @collection: 'users'
    @coerce: (item) ->
        delete item['password']
        item

class Messages extends orm.Collection
    @singular: 'message'
    @collection: 'messages'

module.exports = {
    Users
    Messages
}
