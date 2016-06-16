Collection = require("./collection")
ManyToManyCollection = require("./many_to_many_collection")
utils = require("./utils")

class Relation
  @belongsTo: (instance, relationClass) ->
    record = relationClass.dao().get(instance["#{utils.dfl(relationClass.name)}Id"])
    return null unless record
    relationClass.build(record)

  @hasOne: (instance, relationClass) ->
    obj = {}
    obj["#{utils.dfl(instance.constructor.name)}Id"] = instance.id
    record = relationClass.dao().getAll(obj)[0]
    return null unless record
    relationClass.build(record)

  @hasMany: (instance, relationClass) ->
    obj = {}
    obj["#{utils.dfl(instance.constructor.name)}Id"] = instance.id
    new Collection(obj, relationClass)

  @manyToMany: (instance, joinClass, relationClass, selfClass) ->
    obj = {}
    obj["#{utils.dfl(selfClass.name)}Id"] = instance.id
    ids = joinClass.dao().getAll(obj).map((obj) -> obj["#{utils.dfl(relationClass.name)}Id"])
    new ManyToManyCollection(
      { id: ids },
      relationClass,
      { joinModel: joinClass, model: selfClass, id: instance.id }
    )

module.exports = Relation
