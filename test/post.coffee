Model = require("../src/model")

class Post extends Model
  @attributes('name', 'description')
  @hasOne('Author', { dependent: 'destroy' })
  @hasMany('Comment', { dependent: 'destroy' })

  saySomething: (something) -> something

module.exports = Post
