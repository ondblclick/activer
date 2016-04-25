Collection = require("./collection")
utils = require("./utils")

class Model
  @constructors: {}

  @pushToCtorsList: (constructor) ->
    Model.constructors[constructor.name] = constructor

  @inCtorsList: (constructor) ->
    !!Model[constructor.name]

  @belongsTo: (models...) ->
    @pushToCtorsList(@) unless @inCtorsList(@)
    klass = @
    models.forEach (m) ->
      klass.fields.push("#{utils.dfl(m)}Id")
      klass::["#{utils.dfl(m)}"] = ->
        relationClass = Model.constructors[m]
        relationInstance = relationClass.find(@["#{utils.dfl(m)}Id"])
        relationInstance

  @hasOne: (models...) ->
    @pushToCtorsList(@) unless @inCtorsList(@)
    klass = @
    models.forEach (m) ->
      klass::["#{utils.dfl(m)}"] = ->
        relationClass = Model.constructors[m]
        obj = {}
        obj["#{utils.dfl(klass.name)}Id"] = @id
        relationClass.where(obj)[0]

      klass::["create#{m}"] = (props = {}) ->
        obj = {}
        obj["#{utils.dfl(klass.name)}Id"] = @id
        relationClass = Model.constructors[m]
        relationClass.create(utils.extend(props, obj))

  @hasMany: (models...) ->
    @pushToCtorsList(@) unless @inCtorsList(@)
    klass = @
    models.forEach (m) ->
      klass::["#{utils.dfl(m)}s"] = ->
        relationClass = Model.constructors[m]
        obj = {}
        obj["#{utils.dfl(klass.name)}Id"] = @id
        new Collection(@, relationClass, relationClass.where(obj)...)

  @attributes: (attributes...) ->
    @fields = @fields or []
    attributes.forEach (attribute) =>
      @fields.push attribute
    @fields = utils.uniq(@fields)

  @create: (props = {}) ->
    instance = new @()
    instance.id = props.id or utils.uniqueId("#{utils.dfl(@name)}")
    @fields.forEach (field) ->
      instance[field] = props[field]
    @collection = @collection or []
    @fields = @fields or []
    @collection.push(instance)
    instance

  @all: -> @collection or []
  @find: (id) -> @where({ id: id })[0]
  @where: (props) -> utils.where(@all(), props)
  @deleteAll: -> @collection = []

  destroy: ->
    index = @constructor.collection.indexOf(@)
    @constructor.collection.splice(index, 1) unless index is -1

  toJSON: ->
    res = {}
    @constructor.fields.forEach (field) =>
      res[field] = @[field]
    res

module.exports = Model
