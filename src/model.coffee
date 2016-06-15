Collection = require("./collection")
ManyToManyCollection = require("./many_to_many_collection")
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
      record = Model._getClass(model).dao().get(@["#{utils.dfl(model)}Id"])
      return null unless record
      Model._getClass(model).build(record)

  @hasOne: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasOne')

    @::[utils.dfl(model)] = ->
      obj = {}
      obj["#{utils.dfl(@constructor.name)}Id"] = @id
      record = Model._getClass(model).dao().getAll(obj)[0]
      return null unless record
      Model._getClass(model).build(record)

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
      # if many-to-many
      joinClassName = options.through
      klass = @

      # the same as HABTM, most likely
      @::["#{utils.dfl(model)}s"] = ->
        obj = {}
        obj["#{utils.dfl(@constructor.name)}Id"] = @id
        joinTableObjects = Model._getClass(joinClassName).where(obj)
        ids = joinTableObjects.map((obj) -> obj["#{utils.dfl(model)}Id"])
        new ManyToManyCollection(
          { id: ids },
          Model._getClass(model),
          { joinModel: Model._getClass(joinClassName), model: klass, id: @id }
        )

    else
      # if direct has_many
      @::["#{utils.dfl(model)}s"] = ->
        obj = {}
        obj["#{utils.dfl(@constructor.name)}Id"] = @id
        new Collection(obj, Model._getClass(model))

  @hasAndBelongsToMany: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasAndBelongsToMany')

    joinClassName = [model, @name].sort().join('')
    klass = @

    # @::["#{utils.dfl(joinClassName)}s"] = ->
    #   obj = {}
    #   obj["#{utils.dfl(@constructor.name)}Id"] = @id
    #   new Collection(obj, Model._getClass(joinClassName))

    @::["#{utils.dfl(model)}s"] = ->
      obj = {}
      obj["#{utils.dfl(@constructor.name)}Id"] = @id
      joinTableObjects = Model._getClass(joinClassName).where(obj)
      ids = joinTableObjects.map((obj) -> obj["#{utils.dfl(model)}Id"])
      new ManyToManyCollection(
        { id: ids },
        Model._getClass(model),
        { joinModel: Model._getClass(joinClassName), model: klass, id: @id }
      )

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
      instance[prop] = props[prop] if prop in @attributes() and !Array.isArray(props[prop])
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
    return unless @dao().get(id)
    @build(@dao().get(id))

  @where: (props = {}) ->
    new Collection(props, @)

  @deleteAll: ->
    @dao().removeAll()

  @destroyAll: ->
    @all().forEach((obj) -> obj.destroy())

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

    @constructor._getRelationsToBeDeleted().forEach (relation) =>
      if relation.type is 'hasMany'
        @["#{utils.dfl(relation.name)}s"]().destroyAll()
      if relation.type is 'hasOne' or relation.type is 'belongsTo'
        @[utils.dfl(relation.name)]().destroy()

      # HABTM should not support dependent destroy :)
      # if relation.type is 'hasAndBelongsToMany'
      #   @["#{utils.dfl(relation.name)}s"]().destroyAll()
      #   @["#{utils.dfl([@constructor.name, relation.name].sort().join(''))}s"]().destroyAll()

    @afterDestroy()

  toJSON: ->
    res = {}
    @constructor.attributes().forEach (field) =>
      res[field] = @[field]
    res

module.exports = Model
