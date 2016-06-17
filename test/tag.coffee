Model = require("../src/model")
Post = require("./post")
PostTag = require("./post_tag")

class Tag extends Model
  @attributes('name')
  @hasAndBelongsToMany('Post')

module.exports = Tag
