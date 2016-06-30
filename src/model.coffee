Collection = require("./collection")
Relation = require('./relation')
utils = require("./utils")
dao = require("./dao")

class Model
  @_constructors: {}

  @_getClass: (name) ->
    Model._constructors[name]

  @_addToConstructorsList: (constructor) ->
    Model._constructors[constructor.name] = constructor

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
      Relation.belongsTo(@, Model._getClass(model))

  @hasOne: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasOne')

    @::[utils.dfl(model)] = ->
      Relation.hasOne(@, Model._getClass(model))

    @::["create#{model}"] = (props = {}) ->
      obj = {}
      obj["#{utils.dfl(@constructor.name)}Id"] = @id

      # check if relation is already there and remove it
      record = Model._getClass(model).dao().getAll(obj)[0]
      Model._getClass(model).dao().remove(record.id) if record

      # create new relation
      Model._getClass(model).create(utils.extend(props, obj))

  @hasMany: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasMany')

    if options and options.through
      joinClassName = options.through
      klass = @

      @::["#{utils.dfl(model)}s"] = ->
        Relation.manyToMany(@, Model._getClass(joinClassName), Model._getClass(model), klass)

    else
      @::["#{utils.dfl(model)}s"] = ->
        Relation.hasMany(@, Model._getClass(model))

  @hasAndBelongsToMany: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasAndBelongsToMany')

    joinClassName = [model, @name].sort().join('')
    klass = @

    @::["#{utils.dfl(model)}s"] = ->
      Relation.manyToMany(@, Model._getClass(joinClassName), Model._getClass(model), klass)

  @attributes: (attributes...) ->
    if attributes.length
      @_fields = @_fields or ['id']
      attributes.forEach (attribute) =>
        @_fields.push attribute
        @_fields = utils.uniq(@_fields)
    else
      @_fields or ['id']
    @_fields

  @build: (props = {}) ->
    instance = new @()
    Object.keys(props).forEach (prop) =>
      return unless prop in @attributes()
      return if Array.isArray(props[prop])
      instance[prop] = props[prop]
    instance

  @create: (props = {}) ->
    instance = @build(props)
    instance.id = instance.id or utils.uniqueId(utils.dfl(@name))
    @dao().create(utils.extend(props, { id: instance.id }))
    instance.afterCreate()
    instance

  @all: ->
    new Collection({}, @)

  @find: (id) ->
    new Collection({}, @).find(id)

  @where: (props = {}) ->
    new Collection(props, @)

  @deleteAll: ->
    new Collection({}, @).deleteAll()

  @destroyAll: ->
    new Collection({}, @).destroyAll()

  @collection: (@externalDao) ->

  @dao: ->
    @d = @externalDao or dao() if not @d
    @d

  afterCreate: ->

  afterDestroy: ->

  update: (props) ->
    for key, value of props
      @[key] = value if key in @constructor.attributes()
    @save()

  save: ->
    @constructor.dao().update(@id, @toJSON())

  remove: ->
    @constructor.dao().remove(@id)

  destroy: ->
    @remove()

    # remove all dependent: destroy relations
    @constructor._getRelationsToBeDeleted().forEach (relation) =>
      if relation.type is 'hasMany'
        @["#{utils.dfl(relation.name)}s"]().destroyAll()
      if relation.type in ['hasOne', 'belongsTo']
        @[utils.dfl(relation.name)]().destroy() if @[utils.dfl(relation.name)]()

    # remove join table records
    for key, value of @constructor._relations
      if value.type is 'hasMany'
        if value.options and value.options.through
          @["#{utils.dfl(value.options.through)}s"]().destroyAll()
      if value.type is 'hasAndBelongsToMany'
        joinClassName = [@constructor.name, key].sort().join('')
        obj = {}
        obj["#{utils.dfl(@constructor.name)}Id"] = @id
        Model._getClass(joinClassName).where(obj).destroyAll()

    @afterDestroy()

  toJSON: ->
    res = {}
    @constructor.attributes().forEach (field) =>
      res[field] = @[field]
    res

if typeof window isnt 'undefined'
  window.Model = Model
else
  module.exports = Model
