DataService = require 'data-service'
config = require '../config'

aws_auth = config.aws_auth
    
data_service = new DataService 'room:data', {
    type: 'dynamo'
    config: {
        project_slug: "room"
        aws_auth
        db: config?.dynamo?.db or 'room'
        id_key: 'id'
        strict_auth: false
    }
}, {}
