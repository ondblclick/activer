Collection = require("./collection")
utils = require("./utils")
dao = require("./dao")

class Model
  @_constructors: {}

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
      relationClass = Model._constructors[model]
      record = relationClass.dao().get(@["#{utils.dfl(model)}Id"])
      return null unless record
      relationClass.build(record)

  @hasOne: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasOne')

    @::[utils.dfl(model)] = ->
      relationClass = Model._constructors[model]
      obj = {}
      obj["#{utils.dfl(@constructor.name)}Id"] = @id
      record = relationClass.dao().getAll(obj)[0]
      return null unless record
      relationClass.build(record)

    @::["create#{model}"] = (props = {}) ->
      obj = {}
      obj["#{utils.dfl(@constructor.name)}Id"] = @id
      relationClass = Model._constructors[model]

      # check if relation is already there and remove it
      record = relationClass.dao().getAll(obj)[0]
      relationClass.dao().remove(record.id) if record

      # create new relation
      relationClass.create(utils.extend(props, obj))

  @hasMany: (model, options) ->
    @_addToConstructorsList(@)
    @_addToRelationsList(model, options, 'hasMany')

    @::["#{utils.dfl(model)}s"] = ->
      relationClass = Model._constructors[model]
      obj = {}
      obj["#{utils.dfl(@constructor.name)}Id"] = @id
      new Collection(obj, relationClass, relationClass.dao().getAll(obj))

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

  @all: ->
    new Collection({}, @, @dao().getAll())

  @find: (id) ->
    return unless @dao().get(id)
    @build(@dao().get(id))

  @where: (props = {}) ->
    new Collection(props, @, @dao().getAll(props))

  @deleteAll: -> @dao().removeAll()
  @destroyAll: -> @all().forEach((obj) -> obj.destroy())

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
