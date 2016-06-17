Author = require("./author")
Comment = require("./comment")
Post = require("./post")
Tag = require("./tag")
Category = require("./category")
PostTag = require("./post_tag")
CategoryPost = require("./category_post")
expect = require('chai').expect

describe 'Model', ->
  beforeEach ->
    Post.deleteAll()
    Comment.deleteAll()
    Author.deleteAll()
    Category.deleteAll()
    CategoryPost.deleteAll()

  describe 'relations', ->
    describe '#hasAndBelongsToMany', ->
      it 'relation method returns many-to-many collection', ->
        post = Post.create()
        tag = Tag.create()
        expect(post.tags().constructor.name).to.eq 'ManyToManyCollection'
        expect(tag.posts().constructor.name).to.eq 'ManyToManyCollection'

      it 'collection contains proper values', ->
        post = Post.create()
        tag1 = Tag.create({ name: 'Tag name 1' })
        tag2 = Tag.create({ name: 'Tag name 2' })
        tag3 = Tag.create({ name: 'Tag name 3' })
        PostTag.create({ postId: post.id, tagId: tag1.id })
        PostTag.create({ postId: post.id, tagId: tag2.id })
        PostTag.create({ postId: post.id, tagId: tag3.id })
        expect(post.tags().length).to.eq 3
        expect(post.tags()[0]).to.deep.eq tag1
        expect(tag1.posts().length).to.eq 1
        expect(tag1.posts()[0]).to.deep.eq post

    describe '#hasMany', ->
      it 'relation method returns one-to-many collection', ->
        post = Post.create()
        expect(post.comments().constructor.name).to.eq 'Collection'

      it 'collection contains proper values', ->
        post = Post.create()
        comment1 = Comment.create({ postId: post.id })
        comment2 = Comment.create({ postId: post.id })
        comment3 = Comment.create({ postId: post.id })
        expect(post.comments().length).to.eq 3
        expect(post.comments()[0]).to.deep.eq comment1

      describe "{ dependent: 'destroy' }", ->
        it 'OK if #destroy', ->
          post = Post.create()
          post.categorys().create()
          post.categorys().create()
          post.categorys().create()
          expect(Post.all().length).to.eq 1
          expect(Category.all().length).to.eq 3
          expect(CategoryPost.all().length).to.eq 3
          post.destroy()
          expect(Post.all().length).to.eq 0
          expect(Category.all().length).to.eq 0
          expect(CategoryPost.all().length).to.eq 0

        it 'OK if #remove', ->
          post = Post.create()
          post.categorys().create()
          post.categorys().create()
          post.categorys().create()
          expect(Post.all().length).to.eq 1
          expect(Category.all().length).to.eq 3
          expect(CategoryPost.all().length).to.eq 3
          post.remove()
          expect(Post.all().length).to.eq 0
          expect(Category.all().length).to.eq 3
          expect(CategoryPost.all().length).to.eq 3

      describe "{ through: 'something' }", ->
        it 'relation method returns many-to-many collection', ->
          post = Post.create()
          category = Category.create()
          expect(post.categorys().constructor.name).to.eq 'ManyToManyCollection'
          expect(category.posts().constructor.name).to.eq 'ManyToManyCollection'

        it 'collection contains proper values', ->
          post = Post.create()
          category1 = Category.create({ name: 'Category name 1' })
          category2 = Category.create({ name: 'Category name 2' })
          category3 = Category.create({ name: 'Category name 3' })
          CategoryPost.create({ postId: post.id, categoryId: category1.id })
          CategoryPost.create({ postId: post.id, categoryId: category2.id })
          CategoryPost.create({ postId: post.id, categoryId: category3.id })
          expect(post.categorys().length).to.eq 3
          expect(post.categorys()[0]).to.deep.eq category1
          expect(category1.posts().length).to.eq 1
          expect(category1.posts()[0]).to.deep.eq post

    describe '#hasOne', ->
      it 'relation method returns model instance', ->
        post = Post.create()
        author = Author.create({ postId: post.id })
        expect(post.author().constructor.name).to.eq 'Author'

      it 'instance has method to create relation', ->
        post = Post.create()
        expect(post.createAuthor).to.not.eq undefined
        expect(post.createAuthor().postId).to.eq post.id

      it 'relations is a proper object', ->
        post = Post.create()
        author = post.createAuthor()
        expect(post.author()).to.deep.eq author

      describe "{ dependent: 'destroy' }", ->
        it 'OK if #destroy', ->
          post = Post.create()
          author = post.createAuthor()
          expect(Post.all().length).to.eq 1
          expect(Author.all().length).to.eq 1
          post.destroy()
          expect(Post.all().length).to.eq 0
          expect(Author.all().length).to.eq 0

        it 'OK if #remove', ->
          post = Post.create()
          author = post.createAuthor()
          expect(Post.all().length).to.eq 1
          expect(Author.all().length).to.eq 1
          post.remove()
          expect(Post.all().length).to.eq 0
          expect(Author.all().length).to.eq 1

    describe '#belongsTo', ->
      it 'relation method returns model instance', ->
        post = Post.create()
        author = Author.create({ postId: post.id })
        expect(author.post().constructor.name).to.eq 'Post'

      it 'relations is a proper object', ->
        post = Post.create()
        author = post.createAuthor()
        expect(author.post()).to.deep.eq post

      describe "{ dependent: 'destroy' }", ->
        it 'OK if #destroy', ->
          post = Post.create()
          author = post.createAuthor()
          expect(Post.all().length).to.eq 1
          expect(Author.all().length).to.eq 1
          author.destroy()
          expect(Post.all().length).to.eq 0
          expect(Author.all().length).to.eq 0

        it 'OK if #remove', ->
          post = Post.create()
          author = post.createAuthor()
          expect(Post.all().length).to.eq 1
          expect(Author.all().length).to.eq 1
          author.remove()
          expect(Post.all().length).to.eq 1
          expect(Author.all().length).to.eq 0

  describe 'static', ->
    describe '#attributes', ->
      it 'returns a set of fields if no arguments passed', ->
        expect(Post.attributes()).to.deep.eq ['id', 'name', 'description']

      it 'adds a field to a set if arguments passed', ->
        Post.attributes('something')
        expect(Post.attributes()).to.deep.eq ['id', 'name', 'description', 'something']

    describe '#delegate', ->
      it 'works', ->
        post = Post.create()
        expect(post.saySomething('something')).to.eql 'something'
        author = post.createAuthor()
        expect(author.saySomething('another thing')).to.eql 'another thing'
        expect(author.comments().length).to.eql 0
        post.comments().create()
        expect(author.comments().length).to.eql 1

    describe '#create', ->
      it 'works', ->
        expect(Post.all().length).to.eql 0
        post = Post.create()
        expect(Post.all().length).to.eql 1
        expect(Post.all()[0]).to.eql post

    describe '#build', ->
      it 'works', ->
        post = Post.build()
        expect(Post.all().length).to.eq 0
        expect(post.constructor.name).to.eq 'Post'

    describe '#find', ->
      beforeEach ->
        [1..10].forEach (index) -> Post.create({ id: index })

      it 'returns a model instance', ->
        expect(Post.find(1).constructor.name).to.eq 'Post'

      it 'returns proper object if all OK', ->
        expect(Post.find(1)).to.not.eql undefined

      it 'return undefined if no object was found', ->
        expect(Post.find(15)).to.eql undefined

    describe '#all', ->
      it 'returns collection instance', ->
        post = Post.create()
        expect(Post.all().constructor.name).to.eq 'Collection'

    describe '#where', ->
      it 'returns collection instance', ->
        post = Post.create()
        expect(Post.where().constructor.name).to.eq 'Collection'

  describe 'instance', ->
    describe '#destroy', ->
      it 'triggers dependent: destroy', ->
        post = Post.create()
        author = post.createAuthor()
        expect(Post.all().length).to.eq 1
        expect(Author.all().length).to.eq 1
        post.destroy()
        expect(Post.all().length).to.eq 0
        expect(Author.all().length).to.eq 0

      it 'triggers afterDestroy callback', ->
        # pending

    describe '#remove', ->
      it 'not triggers dependent: destroy', ->
        post = Post.create()
        author = post.createAuthor()
        expect(Post.all().length).to.eq 1
        expect(Author.all().length).to.eq 1
        post.remove()
        expect(Post.all().length).to.eq 0
        expect(Author.all().length).to.eq 1

      it 'not triggers afterDestroy callback', ->
        # pending

    describe '#save', ->
      it 'works', ->
        post = Post.create()
        expect(post.name).to.eql undefined
        expect(Post.find(post.id).name).to.eql undefined
        post.name = 'postName'
        expect(post.name).to.eql 'postName'
        expect(Post.find(post.id).name).to.eql undefined
        post.save()
        expect(post.name).to.eql 'postName'
        expect(Post.find(post.id).name).to.eql 'postName'

    describe '#update', ->
      it 'works', ->
        post = Post.create()
        expect(post.name).to.eql undefined
        expect(Post.find(post.id).name).to.eql undefined
        post.update({ name: 'postName' })
        expect(post.name).to.eql 'postName'
        expect(Post.find(post.id).name).to.eql 'postName'

    describe '#toJSON', ->
      it 'works', ->
        Post._fields = ['id', 'name', 'description']
        post = Post.create({ name: 'name', description: 'description' })
        expect(post.toJSON()).to.eql
          name: 'name'
          description: 'description'
          id: post.id
