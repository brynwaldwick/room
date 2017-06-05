
bodyContains = (body, str) ->
    body.toLowerCase().indexOf(str) > -1
bodyContainsEither = (body, arr) ->
    words_contained = arr.filter (w) ->
        body.toLowerCase().indexOf(w) > -1
    return words_contained?.length

module.exports = {bodyContains, bodyContainsEither}
