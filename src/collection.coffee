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
    @forEach (object) -> object.destroy()

  where: (props) => utils.where(@, props)

  find: (id) -> @where({ id: id })[0]

module.exports = Collection
