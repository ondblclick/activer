Model = require("../src/model")

class Post extends Model
  @attributes('name', 'description')
  @hasOne('Author')
  @hasMany('Comment')

module.exports = Post
