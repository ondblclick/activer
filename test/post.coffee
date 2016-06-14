Model = require("../src/model")
Tag = require("./tag")
PostTag = require("./post_tag")

class Post extends Model
  @attributes('name', 'description')
  @hasOne('Author', { dependent: 'destroy' })
  @hasMany('Comment')
  @hasAndBelongsToMany('Tag')

  saySomething: (something) -> something

module.exports = Post
