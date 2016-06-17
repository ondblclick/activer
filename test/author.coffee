Model = require("../src/model")

class Author extends Model
  @belongsTo('Post', { dependent: 'destroy' })
  @delegate('saySomething', 'Post')
  @delegate('comments', 'Post')

module.exports = Author
