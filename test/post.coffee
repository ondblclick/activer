Model = require("../src/model")

posts = {
  collection: [],

  delete: (id) ->
    @collection = @collection.filter (el) -> el.id isnt id

  deleteAll: (options) ->
    if options
      toBeDeletedIds = @where(options).map (el) -> el.id
      @collection = @collection.filter (el) -> toBeDeletedIds.indexOf(el.id) is -1
    else
      @collection = []

  add: (object) ->
    @collection.push(object)
    JSON.parse(JSON.stringify(object))

  where: (options) ->
    res = []
    @collection.forEach (object) ->
      all = true
      for key, value of options
        all = false if object[key] isnt value
      res.push object if all
    res

  find: (id) ->
    @where({ id: id })[0]
}

class Post extends Model
  @collection(-> posts)
  @attributes('name', 'description')
  @hasOne('Author', { dependent: 'destroy' })
  @hasMany('Comment')

  saySomething: (something) -> something

module.exports = Post
