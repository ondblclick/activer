class @Collection extends Array
  constructor: (@parent, @model, items...) ->
    @splice 0, 0, items...

  create: (props) =>
    props = props or {}
    obj = {}
    obj["#{@parent.constructor.name.toLowerCase()}_id"] = @parent.id
    @model.create(utils.extend(props, obj))

  deleteAll: =>
    @model.collection = utils.filter @model.collection, (object) =>
      @indexOf(object) is -1
