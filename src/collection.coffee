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
    @model.dao().deleteAll(obj)

  destroyAll: ->

  where: (props) =>
    obj = {}
    obj["#{utils.dfl(@parent.constructor.name)}Id"] = @parent.id
    @model.dao().getAll(utils.extend(props, obj)).map((obj) -> @model.build(obj))

  find: (id) ->
    return unless @model.dao().get(id)
    @model.build(@model.dao().get(id))

module.exports = Collection
