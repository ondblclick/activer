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

  describe 'adds properties', ->
    it 'for class with hasAndBelongsToMany method called', ->
      post = Post.create()
      tag1 = Tag.create({ name: 'Tag name 1' })
      tag2 = Tag.create({ name: 'Tag name 2' })
      tag3 = Tag.create({ name: 'Tag name 3' })
      PostTag.create({ postId: post.id, tagId: tag1.id })
      PostTag.create({ postId: post.id, tagId: tag2.id })
      PostTag.create({ postId: post.id, tagId: tag3.id })
      expect(post.tags().length).to.eq 3
      expect(post.tags()[0]).to.deep.eq tag1
      expect(post.tags().where({ name: ['Tag name 1', 'Tag name 2'] }).length).to.eq 2
      expect(tag1.posts().length).to.eq 1
      expect(tag1.posts()[0]).to.deep.eq post

    it 'for class with hasMany { through: } method called', ->
      post = Post.create()
      category1 = Category.create({ name: 'Category name 1' })
      category2 = Category.create({ name: 'Category name 2' })
      category3 = Category.create({ name: 'Category name 3' })
      CategoryPost.create({ postId: post.id, categoryId: category1.id })
      CategoryPost.create({ postId: post.id, categoryId: category2.id })
      CategoryPost.create({ postId: post.id, categoryId: category3.id })
      expect(post.categorys().length).to.eq 3
      expect(post.categorys()[0]).to.deep.eq category1
      expect(post.categorys().where({ name: ['Category name 1', 'Category name 2'] }).length).to.eq 2
      expect(category1.posts().length).to.eq 1
      expect(category1.posts()[0]).to.deep.eq post

    it 'for class with belongsTo method called', ->
      post = Post.create()
      author1 = Author.create({ postId: post.id })
      expect(author1.post()).to.eql post
      author2 = Author.create({ postId: null })
      expect(author2.post()).to.eql null

    it 'for class with hasOne method called', ->
      post1 = Post.create()
      post2 = Post.create()
      post3 = Post.create()
      author1 = Author.create({ postId: post1.id })
      author2 = post2.createAuthor()
      expect(post1.author()).to.eql author1
      expect(post2.author()).to.eql author2
      expect(post3.author()).to.eql null
      author3 = post2.createAuthor()
      expect(post2.author()).to.not.eql author2
      expect(post2.author()).to.eql author3

    it 'for class with hasMany method called', ->
      post = Post.create()
      expect(post.comments().length).to.eq 0
      comment1 = Comment.create({ postId: post.id })
      comment2 = Comment.create({ postId: post.id })
      comment3 = Comment.create()
      expect(Comment.all().length).to.eql 3
      expect(post.comments().length).to.eql 2
      expect(post.comments()[0]).to.eql comment1
      expect(post.comments()[1]).to.eql comment2

  it '#toJSON', ->
    post = Post.create({ name: 'name', description: 'description' })
    expect(post.toJSON()).to.eql
      name: 'name'
      description: 'description'
      id: post.id

  it '#save', ->
    post = Post.create()
    expect(post.name).to.eql undefined
    expect(Post.find(post.id).name).to.eql undefined
    post.name = 'postName'
    expect(post.name).to.eql 'postName'
    expect(Post.find(post.id).name).to.eql undefined
    post.save()
    expect(post.name).to.eql 'postName'
    expect(Post.find(post.id).name).to.eql 'postName'

  it '#update', ->
    post = Post.create()
    expect(post.name).to.eql undefined
    expect(Post.find(post.id).name).to.eql undefined
    post.update({ name: 'postName' })
    expect(post.name).to.eql 'postName'
    expect(Post.find(post.id).name).to.eql 'postName'

  it '#remove', ->

  it '#destroy', ->

  describe 'adds useful static method', ->
    it '#all', ->
      [1..10].forEach -> Post.create()
      expect(Post.all().length).to.eql 10
      expect(Post.all().constructor.name).to.eql 'Collection'

    it '#find', ->
      [1..10].forEach (index) -> Post.create({ id: index })
      expect(Post.find(1)).to.not.eql undefined
      expect(Post.find(15)).to.eql undefined

    it '#where', ->
      [1..10].forEach (index) -> Post.create({ id: index })
      expect(Post.where({ id: 1 }).length).to.eql 1
      expect(Post.where({ id: 20 }).length).to.eql 0
      expect(Post.where({ id: 20 }).constructor.name).to.eql 'Collection'

    it '#where with array', ->
      [1..10].forEach (index) -> Post.create({ id: index, name: "Post name #{index % 2}" })
      expect(Post.where({ id: [1, 2, 3] }).length).to.eql 3
      expect(Post.where({ id: [1, 2, 3, 4], name: "Post name 1" }).length).to.eql 2

    it '#create', ->
      expect(Post.all().length).to.eql 0
      post = Post.create()
      expect(Post.all().length).to.eql 1
      expect(Post.all()[0]).to.eql post

    it '#deleteAll (not triggering callbacks)', ->
      post1 = Post.create()
      post2 = Post.create()
      author1 = post1.createAuthor()
      author2 = post2.createAuthor()
      category1 = post1.categorys().create()
      category2 = post2.categorys().create()
      expect(Post.all().length).to.eq 2
      expect(Author.all().length).to.eq 2
      expect(Category.all().length).to.eq 2
      expect(CategoryPost.all().length).to.eq 2
      Post.deleteAll()
      expect(Post.all().length).to.eq 0
      expect(Author.all().length).to.eq 2
      expect(Category.all().length).to.eq 2
      expect(CategoryPost.all().length).to.eq 2

    it '#destroyAll (triggering callbacks)', ->
      post1 = Post.create()
      post2 = Post.create()
      author1 = post1.createAuthor()
      author2 = post2.createAuthor()
      category1 = post1.categorys().create()
      category2 = post2.categorys().create()
      expect(Post.all().length).to.eq 2
      expect(Author.all().length).to.eq 2
      expect(Category.all().length).to.eq 2
      expect(CategoryPost.all().length).to.eq 2
      Post.destroyAll()
      expect(Post.all().length).to.eq 0
      expect(Author.all().length).to.eq 0
      expect(Category.all().length).to.eq 0
      expect(CategoryPost.all().length).to.eq 0

    it '#delegate', ->
      post = Post.create()
      expect(post.saySomething('something')).to.eql 'something'
      author = post.createAuthor()
      expect(author.saySomething('another thing')).to.eql 'another thing'
      expect(author.comments().length).to.eql 0
      post.comments().create()
      expect(author.comments().length).to.eql 1
