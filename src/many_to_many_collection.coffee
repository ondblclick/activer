utils = require("./utils")
Collection = require("./collection")

class ManyToManyCollection extends Collection
  constructor: (@params, @model, @origin) ->
    super

  _build: (obj) =>
    @model.build(obj)

  where: (props = {}) =>
    newParams = utils.extend(props, @params)
    new ManyToManyCollection(newParams, @model, @origin)

  create: (props = {}) ->
    newParams = utils.extend(props, @params)
    newInstance = @model.create(newParams)
    obj = {}
    obj["#{utils.dfl(@model.name)}Id"] = newInstance.id
    obj["#{utils.dfl(@origin.model.name)}Id"] = @origin.id
    @origin.joinModel.create(obj)
    newInstance

module.exports = ManyToManyCollection
