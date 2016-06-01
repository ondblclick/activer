Model = require("../src/model")

comments = []

class Comment extends Model
  @collection(-> comments)
  @belongsTo('Post')

module.exports = Comment
