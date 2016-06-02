Model = require("../src/model")
dao = require("../src/dao")

class Post extends Model
  @collection(dao())
  @attributes('name', 'description')
  @hasOne('Author', { dependent: 'destroy' })
  @hasMany('Comment')

  saySomething: (something) -> something

module.exports = Post
