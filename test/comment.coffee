Model = require("../src/model")
dao = require("../src/dao")

class Comment extends Model
  @collection(dao())
  @belongsTo('Post')

module.exports = Comment
