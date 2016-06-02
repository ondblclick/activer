Model = require("../src/model")
dao = require("../src/dao")

class Author extends Model
  @collection(dao())
  @belongsTo('Post')
  @delegate('saySomething', 'Post')
  @delegate('comments', 'Post')

module.exports = Author
