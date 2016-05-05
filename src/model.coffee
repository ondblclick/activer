Collection = require("./collection")
utils = require("./utils")

class Model
  @constructors: {}

  @_addToConstructorsList: (constructor) ->
    Model.constructors[constructor.name] = constructor

  @_getRelationsToBeDeleted: ->
    res = []
    for k, v of @relations
      if v.options and v.options.dependent is 'destroy'
        res.push { type: v.type, name: k }
    res

  @_addToRelationsList: (model, options, type) ->
    @relations = @relations or {}
    @relations[model] =
      type: type
      options: options

  @delegate: (method, target) ->
    @::[method] = -> @["#{utils.dfl(target)}"]()[method]()

  @belongsTo: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'belongsTo')

    @fields = @fields or ['id']
    @fields.push("#{utils.dfl(model)}Id")
    @::["#{utils.dfl(model)}"] = ->
      relationClass = Model.constructors[model]
      relationInstance = relationClass.find(@["#{utils.dfl(model)}Id"])
      relationInstance

  @hasOne: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasOne')

    @fields = @fields or ['id']
    klass = @

    klass::["#{utils.dfl(model)}"] = ->
      relationClass = Model.constructors[model]
      obj = {}
      obj["#{utils.dfl(klass.name)}Id"] = @id
      relationClass.where(obj)[0]

    klass::["create#{model}"] = (props = {}) ->
      obj = {}
      obj["#{utils.dfl(klass.name)}Id"] = @id
      relationClass = Model.constructors[model]
      relationClass.create(utils.extend(props, obj))

  @hasMany: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasMany')

    @fields = @fields or ['id']
    klass = @
    klass::["#{utils.dfl(model)}s"] = ->
      relationClass = Model.constructors[model]
      obj = {}
      obj["#{utils.dfl(klass.name)}Id"] = @id
      new Collection(@, relationClass, relationClass.where(obj)...)

  @attributes: (attributes...) ->
    @fields = @fields or ['id']
    attributes.forEach (attribute) =>
      @fields.push attribute
    @fields = utils.uniq(@fields)

  @create: (props = {}) ->
    instance = new @()
    instance.id = props.id or utils.uniqueId("#{utils.dfl(@name)}")
    Object.keys(props).forEach (prop) ->
      instance[prop] = props[prop]
    @collection = @collection or []
    @fields = @fields or []
    @collection.push(instance)
    instance.afterCreate()
    instance

  @all: -> @collection or []
  @find: (id) -> @where({ id: id })[0]
  @where: (props) -> utils.where(@all(), props)
  @deleteAll: -> @collection = []

  afterCreate: ->

  afterDestroy: ->

  destroy: ->
    index = @constructor.collection.indexOf(@)
    @constructor.collection.splice(index, 1) unless index is -1

    @constructor._getRelationsToBeDeleted().forEach (relation) =>
      if relation.type is 'hasMany'
        @["#{utils.dfl(relation.name)}s"]().deleteAll()
      if relation.type is 'hasOne' or relation.type is 'belongsTo'
        @["#{utils.dfl(relation.name)}"]().destroy()

    @afterDestroy()

  toJSON: ->
    res = {}
    @constructor.fields.forEach (field) =>
      res[field] = @[field]
    res

module.exports = Model
