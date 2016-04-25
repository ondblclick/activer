Model = require("../src/model")

class Author extends Model
  @attributes()
  @belongsTo('Post')

module.exports = Author
