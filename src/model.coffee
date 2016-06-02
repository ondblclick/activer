Collection = require("./collection")
utils = require("./utils")
dao = require("./dao")

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
    @::[method] = (args) -> @["#{utils.dfl(target)}"]()[method](args)

  @belongsTo: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'belongsTo')

    @fields = @fields or ['id']
    @fields.push("#{utils.dfl(model)}Id")
    @::["#{utils.dfl(model)}"] = ->
      relationClass = Model.constructors[model]
      relationClass.build(relationClass.dao().get(@["#{utils.dfl(model)}Id"]))

  @hasOne: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasOne')

    @fields = @fields or ['id']
    klass = @

    klass::["#{utils.dfl(model)}"] = ->
      relationClass = Model.constructors[model]
      obj = {}
      obj["#{utils.dfl(klass.name)}Id"] = @id
      relationClass.build(relationClass.dao().getAll(obj)[0])

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
      new Collection(@, relationClass, relationClass.dao().getAll(obj).map((o) -> relationClass.build(o))...)

  @attributes: (attributes...) ->
    @fields = @fields or ['id']
    attributes.forEach (attribute) =>
      @fields.push attribute
    @fields = utils.uniq(@fields)

  @build: (props = {}) ->
    instance = new @()
    instance.id = props.id or utils.uniqueId("#{utils.dfl(@name)}")
    Object.keys(props).forEach (prop) ->
      instance[prop] = props[prop]
    @fields = @fields or []
    instance

  @create: (props = {}) ->
    instance = @build(props)
    @dao().create(utils.extend(props, { id: instance.id }))
    instance.afterCreate()
    instance

  @all: -> @dao().collection.map((obj) => @build(obj))
  @find: (id) -> @dao().get(id)
  @where: (props = {}) -> @dao().getAll(props)
  @deleteAll: -> @dao().deleteAll()

  @collection: (@externalDao) ->

  @dao: ->
    @d = @externalDao or dao() if not @d
    @d

  afterCreate: ->

  afterDestroy: ->

  update: (props) ->
    @constructor.dao().update(@id, props)

  destroy: ->
    @constructor.dao().delete(@id)

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
