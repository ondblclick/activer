Model = require("../src/model")
Post = require("./post")
Category = require("./category")

class CategoryPost extends Model
  @belongsTo('Post')
  @belongsTo('Category')

module.exports = CategoryPost
