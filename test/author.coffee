Model = require("../src/model")

class Author extends Model
  @belongsTo('Post')

module.exports = Author
