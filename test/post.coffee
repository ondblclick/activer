Model = require("../src/model")

class Post extends Model
  @attributes()
  @hasOne('Author')
  @hasMany('Comment')

module.exports = Post
