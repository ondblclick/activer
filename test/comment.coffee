Model = require("../src/model")

class Comment extends Model
  @belongsTo('Post')

module.exports = Comment
