utils = require("./utils")

class Collection extends Array
  constructor: (@parent, @model, items...) ->
    @push.apply(@, items)

  create: (props) =>
    props = props or {}
    obj = {}
    obj["#{utils.dfl(@parent.constructor.name)}Id"] = @parent.id
    @model.create(utils.extend(props, obj))

  deleteAll: =>
    obj = {}
    obj["#{utils.dfl(@parent.constructor.name)}Id"] = @parent.id
    @model.coll.deleteAll(obj)

  destroyAll: ->

  where: (props) =>
    obj = {}
    obj["#{utils.dfl(@parent.constructor.name)}Id"] = @parent.id
    @model.coll.getAll(utils.extend(props, obj))

  find: (id) ->
    @model.coll.get(id)

module.exports = Collection
