utils = require("./utils")

class Collection extends Array
  constructor: (@parent, @model, items...) ->
    @push.apply(@, items)

  _buildParentIdObj: =>
    if @parent
      obj = {}
      obj["#{utils.dfl(@parent.constructor.name)}Id"] = @parent.id
      obj
    else
      false

  create: (props) =>
    props = props or {}
    @model.create(utils.extend(props, @_buildParentIdObj()))

  deleteAll: =>
    @model.dao().removeAll(@_buildParentIdObj())

  destroyAll: =>
    @model.dao().getAll(@_buildParentIdObj()).map((obj) => @model.build(obj)).forEach((obj) -> obj.destroy())

  where: (props) =>
    @model.dao().getAll(utils.extend(props, @_buildParentIdObj())).map((obj) => @model.build(obj))

  find: (id) ->
    return unless @model.dao().get(id)
    @model.build(@model.dao().get(id))

module.exports = Collection
