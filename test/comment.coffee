Model = require("../src/model")

class Comment extends Model
  @attributes()
  @belongsTo('Post')

module.exports = Comment
