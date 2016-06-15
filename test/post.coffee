Model = require("../src/model")
Tag = require("./tag")
PostTag = require("./post_tag")
Category = require("./category")
CategoryPost = require("./category_post")

class Post extends Model
  @attributes('name', 'description')
  @hasOne('Author', { dependent: 'destroy' })
  @hasMany('Comment')
  @hasMany('Category', { through: 'CategoryPost', dependent: 'destroy' })
  @hasAndBelongsToMany('Tag')

  saySomething: (something) -> something

module.exports = Post
