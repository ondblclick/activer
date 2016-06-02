utils = require("./utils")

dao = ->
  collection: []

  create: (object) ->
    @collection.push(object)
    JSON.parse(JSON.stringify(object))

  update: (id, props) ->
    rec = @get(id)
    for key, value of props
      rec[key] = value

  delete: (id) ->
    @collection = @collection.filter (el) -> el.id isnt id

  deleteAll: (options) ->
    if options
      toBeDeletedIds = @getAll(options).map (el) -> el.id
      @collection = @collection.filter (el) -> toBeDeletedIds.indexOf(el.id) is -1
    else
      @collection = []

  get: (id) ->
    @getAll({ id: id })[0]

  getAll: (options) ->
    if options
      res = []
      @collection.forEach (object) ->
        all = true
        for key, value of options
          all = false if object[key] isnt value
        res.push object if all
      res
    else
      @collection

module.exports = dao
