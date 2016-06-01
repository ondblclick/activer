Model = require("../src/model")

posts = []

class Post extends Model
  @collection(-> posts)
  @attributes('name', 'description')
  @hasOne('Author', { dependent: 'destroy' })
  @hasMany('Comment')

  saySomething: (something) -> something

module.exports = Post
