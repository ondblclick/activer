Collection = require("../src/collection")
utils = require("../src/utils")

class Model
  @all: -> @collection or []
  @find: (id) -> @where({ id: id })[0]
  @where: (props) -> utils.where(@all(), props)
  @create: (props) -> new @(props)
  @deleteAll: -> @collection = []

  initialize: ->

  constructor: (properties) ->
    @addFields()
    @addAssociations()
    @constructor.collection = @constructor.collection or []
    utils.keys(properties).forEach (key) =>
      @[key] = properties[key] if @fields.indexOf(key) isnt -1
    @id = utils.uniqueId("#{utils.dfl(@constructor.name)}") unless @id
    @constructor.collection.push @
    @initialize()

  destroy: ->
    index = @constructor.collection.indexOf(@)
    @constructor.collection.splice(index, 1) unless index is -1

  addFields: ->
    @fields = @fields || []
    @fields.forEach (field) => @[field] = null
    @fields.push('id')
    @fields = utils.uniq(@fields)

  addAssociations: ->
    @addBelongsToAssociation() if !!@constructor.belongsTo
    @addHasOneAssociation() if !!@constructor.hasOne
    @addHasManyAssociation() if !!@constructor.hasMany

  addBelongsToAssociation: ->
    @constructor.belongsTo().forEach (model) =>
      fieldName = "#{utils.dfl(model.name)}Id"
      @[model.name.toLowerCase()] = =>
        model.find(@[fieldName])

      @[fieldName] = null
      @fields.push(fieldName) if @fields.indexOf(fieldName) is -1

  addHasManyAssociation: ->
    @constructor.hasMany().forEach (model) =>
      @["#{utils.dfl(model.name)}s"] = =>
        obj = {}
        obj["#{utils.dfl(@constructor.name)}Id"] = @id
        new Collection(@, model, model.where(obj)...)

  addHasOneAssociation: ->
    @constructor.hasOne().forEach (model) =>
      fieldName = "#{utils.dfl(@constructor.name)}Id"
      @[utils.dfl(model.name)] = =>
        obj = {}
        obj[fieldName] = @id
        model.where(obj)[0]

      @["create#{model.name}"] = (props = {}) =>
        obj = {}
        obj[fieldName] = @id
        model.create(utils.extend(props, obj))

module.exports = Model