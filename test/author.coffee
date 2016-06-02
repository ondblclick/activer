Model = require("../src/model")

class Author extends Model
  @belongsTo('Post')
  @delegate('saySomething', 'Post')
  @delegate('comments', 'Post')

module.exports = Author
