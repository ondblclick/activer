class @Collection extends Array
  constructor: (@parent, @model, items...) ->
    @splice 0, 0, items...

  create: (props) =>
    props = props or {}
    obj = {}
    obj["#{@parent.constructor.name.toLowerCase()}_id"] = @parent.id
    @model.create(_.extend(props, obj))
