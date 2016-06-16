utils = require("./utils")

class Collection extends Array
  constructor: (@params, @model) ->
    @push.apply(@, @model.dao().getAll(@params).map(@_build))

  _build: (obj) =>
    @model.build(obj)

  _destroy: (obj) ->
    obj.destroy()

  create: (props = {}) ->
    newParams = utils.extend(props, @params)
    @model.create(newParams)

  deleteAll: =>
    @model.dao().removeAll(@params)

  destroyAll: =>
    @model.dao().getAll(@params).map(@_build).map(@_destroy)

  where: (props = {}) ->
    newParams = utils.extend(props, @params)
    new Collection(newParams, @model)

  find: (id) ->
    obj = @model.dao().get(id)
    return unless obj
    @model.build(obj)

module.exports = Collection
