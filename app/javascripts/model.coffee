class @Model
  @all: -> @collection or []
  @find: (id) -> @where({ id: id })[0]
  @where: (props) -> utils.where(@all(), props)
  @create: (props) -> new @(props)

  constructor: (properties) ->
    @addFields()
    @addAssociations()
    @constructor.collection = @constructor.collection or []
    utils.keys(properties).forEach (key) =>
      @[key] = properties[key] if @fields.indexOf(key) isnt -1
    @constructor.collection.push @

  addFields: ->
    @fields = @fields || []
    @fields.forEach (field) => @[field] = null
    @fields.push('id')
    @id = utils.uniqueId("#{@constructor.name.toLowerCase()}_")

  addAssociations: ->
    @addBelongsToAssociation() if !!@belongsTo
    @addHasOneAssociation() if !!@hasOne
    @addHasManyAssociation() if !!@hasMany

  addBelongsToAssociation: ->
    @belongsTo().forEach (model) =>
      @[model.name.toLowerCase()] = =>
        model.find(@["#{model.name.toLowerCase()}_id"])

      @["#{model.name.toLowerCase()}_id"] = null
      @fields.push("#{model.name.toLowerCase()}_id")
      @fields = utils.uniq(@fields)

  addHasManyAssociation: ->
    @hasMany().forEach (model) =>
      @["#{model.name.toLowerCase()}s"] = =>
        obj = {}
        obj["#{@constructor.name.toLowerCase()}_id"] = @id
        new Collection(@, model, model.where(obj)...)

  addHasOneAssociation: ->
    @hasOne().forEach (model) =>
      @[model.name.toLowerCase()] = =>
        obj = {}
        obj["#{@constructor.name.toLowerCase()}_id"] = @id
        model.where(obj)[0]

      @["create#{model.name}"] = (props = {}) =>
        obj = {}
        obj["#{@constructor.name.toLowerCase()}_id"] = @id
        model.create(utils.extend(props, obj))
