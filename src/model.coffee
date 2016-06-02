Collection = require("./collection")
utils = require("./utils")
dao = require("./dao")

class Model
  @constructors: {}

  @_addToConstructorsList: (constructor) ->
    Model.constructors[constructor.name] = constructor

  @_getRelationsToBeDeleted: ->
    res = []
    for k, v of @_relations
      if v.options and v.options.dependent is 'destroy'
        res.push { type: v.type, name: k }
    res

  @_addToRelationsList: (model, options, type) ->
    @_relations = @_relations or {}
    @_relations[model] =
      type: type
      options: options

  @delegate: (method, target) ->
    @::[method] = (args) -> @[utils.dfl(target)]()[method](args)

  @belongsTo: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'belongsTo')
    @attributes("#{utils.dfl(model)}Id")

    @::[utils.dfl(model)] = ->
      relationClass = Model.constructors[model]
      relationClass.build(relationClass.dao().get(@["#{utils.dfl(model)}Id"]))

  @hasOne: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasOne')

    @::[utils.dfl(model)] = ->
      relationClass = Model.constructors[model]
      obj = {}
      obj["#{utils.dfl(@constructor.name)}Id"] = @id
      relationClass.build(relationClass.dao().getAll(obj)[0])

    @::["create#{model}"] = (props = {}) ->
      obj = {}
      obj["#{utils.dfl(@constructor.name)}Id"] = @id
      relationClass = Model.constructors[model]
      relationClass.create(utils.extend(props, obj))

  @hasMany: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasMany')

    @::["#{utils.dfl(model)}s"] = ->
      relationClass = Model.constructors[model]
      obj = {}
      obj["#{utils.dfl(@constructor.name)}Id"] = @id
      new Collection(@, relationClass, relationClass.dao().getAll(obj).map((o) -> relationClass.build(o))...)

  @attributes: (attributes...) ->
    if attributes.length
      @_fields = @_fields or ['id']
      attributes.forEach (attribute) =>
        @_fields.push attribute
        @_fields = utils.uniq(@_fields)
    else
      @_fields or ['id']

  @build: (props = {}) ->
    instance = new @()
    Object.keys(props).forEach (prop) =>
      instance[prop] = props[prop] if prop in @attributes()
    instance

  @create: (props = {}) ->
    instance = @build(props)
    instance.id = instance.id or utils.uniqueId(utils.dfl(@name))
    @dao().create(utils.extend(props, { id: instance.id }))
    instance.afterCreate()
    instance

  @all: -> @dao().getAll().map((obj) => @build(obj))
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
        @[utils.dfl(relation.name)]().destroy()

    @afterDestroy()

  toJSON: ->
    res = {}
    @constructor.attributes().forEach (field) =>
      res[field] = @[field]
    res

module.exports = Model
