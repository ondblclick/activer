utils = require("./utils")
Collection = require("./collection")

class ManyToManyCollection extends Collection
  where: (props = {}) =>
    newParams = utils.extend(props, @params)
    new ManyToManyCollection(newParams, @model, @model.dao().getAll(newParams))

  # should be implemented
  # create: ->

module.exports = ManyToManyCollection
