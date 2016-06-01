Model = require("../src/model")

authors = []

class Author extends Model
  @collection(-> authors)
  @belongsTo('Post')
  @delegate('saySomething', 'Post')
  @delegate('comments', 'Post')

module.exports = Author
