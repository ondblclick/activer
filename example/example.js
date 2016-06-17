var Model = require('activer')

class Post extends Model {}
Post.hasMany('CategoryPost')
Post.hasMany('Category', { through: 'CategoryPost' })
Post.hasMany('Comment', { dependent: 'destroy' })

class Comment extends Model {}
Comment.belongsTo('Post')

class Category extends Model {}
Category.attributes('name')
Category.hasMany('CategoryPost')
Category.hasMany('Post', { through: 'CategoryPost' })

class CategoryPost extends Model {}
CategoryPost.belongsTo('Post')
CategoryPost.belongsTo('Category')

/* working with models defined above */

post = Post.create()
console.log(post.comments().length) // 0
console.log(post.categorys().length) // 0
post.comments().create()
post.categorys().create()
console.log(post.comments().length) // 1
console.log(post.categorys().length) // 1
