Model = require("../src/model")
Post = require("./post")
CategoryPost = require("./category_post")

class Category extends Model
  @attributes('name')
  @hasMany('CategoryPost')
  @hasMany('Post', { through: 'CategoryPost' })

module.exports = Category
