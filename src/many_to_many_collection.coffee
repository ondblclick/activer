utils = require("./utils")

class ManyToManyCollection extends Array
  constructor: (@params, @model, objects) ->
    @push.apply(@, objects.map(@_build))

  _build: (obj) => @model.build(obj)
  _destroy: (obj) -> obj.destroy()

  create: (props = {}) =>
    newParams = utils.extend(props, @params)
    @model.create(newParams)

  deleteAll: =>
    @model.dao().removeAll(@params)

  destroyAll: =>
    @model.dao().getAll(@params).map(@_build).map(@_destroy)

  where: (props = {}) =>
    newParams = utils.extend(props, @params)
    new ManyToManyCollection(newParams, @model, @model.dao().getAll(newParams))

  find: (id) ->
    obj = @model.dao().get(id)
    return unless obj
    @model.build(obj)

module.exports = ManyToManyCollection