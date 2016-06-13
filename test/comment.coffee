Model = require("../src/model")

class Comment extends Model
  @belongsTo('Post')
  @attributes('body')

module.exports = Comment
