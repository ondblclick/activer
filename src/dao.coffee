utils = require("./utils")

dao = ->
  _collection: []

  create: (object) ->
    @_collection.push(object)
    JSON.parse(JSON.stringify(object))

  update: (id, props) ->
    rec = @get(id)
    for key, value of props
      rec[key] = value

  remove: (id) ->
    @_collection = @_collection.filter (el) -> el.id isnt id

  removeAll: (options) ->
    if options
      toBeDeletedIds = @getAll(options).map (el) -> el.id
      @_collection = @_collection.filter (el) -> toBeDeletedIds.indexOf(el.id) is -1
    else
      @_collection = []

  get: (id) ->
    @getAll({ id: id })[0]

  getAll: (options) ->
    if options
      res = []
      @_collection.forEach (object) ->
        all = true
        for key, value of options
          if Array.isArray value
            all = false unless object[key] in value
          else
            all = false if object[key] isnt value
        res.push object if all
      res
    else
      @_collection

module.exports = dao
