Model = require("../src/model")

class Post extends Model
  @attributes('name', 'description')
  @hasOne('Author')
  @hasMany('Comment')

  saySomething: -> 'post instance method called'

module.exports = Post
