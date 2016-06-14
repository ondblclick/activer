Model = require("../src/model")
Post = require("./post")
Tag = require("./tag")

class PostTag extends Model
  @belongsTo('Post')
  @belongsTo('Tag')

module.exports = PostTag
