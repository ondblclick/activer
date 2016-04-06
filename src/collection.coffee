utils = require("./utils")

class Collection extends Array
  constructor: (@parent, @model, items...) ->
    @splice 0, 0, items...

  create: (props) =>
    props = props or {}
    obj = {}
    obj["#{utils.dfl(@parent.constructor.name)}Id"] = @parent.id
    @model.create(utils.extend(props, obj))

  deleteAll: =>
    @model.collection = utils.filter @model.collection, (object) =>
      @indexOf(object) is -1

  where: (props) => utils.where(@, props)

  find: (id) -> @where({ id: id })[0]

module.exports = Collection
