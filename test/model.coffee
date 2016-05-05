Author = require("./author")
Comment = require("./comment")
Post = require("./post")
expect = require('chai').expect

describe 'Model', ->
  beforeEach ->
    Post.deleteAll()
    Comment.deleteAll()
    Author.deleteAll()

  it 'adds toJSON method', ->
    post = Post.create({ name: 'name', description: 'description' })
    expect(post.toJSON()).to.eql
      name: 'name'
      description: 'description'
      id: post.id

  describe 'adds properties', ->
    it 'for class with belongsTo method implemented', ->
      post = Post.create()
      author = Author.create({ postId: post.id })
      expect(author.post()).to.eql post
      expect(author.postId).to.eql post.id

    it 'for class with hasOne method implemented', ->
      post1 = Post.create()
      post2 = Post.create()
      author1 = Author.create({ postId: post1.id })
      author2 = post2.createAuthor()
      expect(post1.author()).to.eql author1
      expect(post2.author()).to.eql author2

    it 'for class with hasMany method implemented', ->
      post = Post.create()
      comment1 = Comment.create({ postId: post.id })
      comment2 = Comment.create({ postId: post.id })
      comment3 = Comment.create()
      expect(Comment.all().length).to.eql 3
      expect(post.comments().length).to.eql 2
      expect(post.comments()[0]).to.eql comment1
      expect(post.comments()[1]).to.eql comment2
      post.comments().deleteAll()
      expect(post.comments()[0]).to.eql undefined
      expect(post.comments()[1]).to.eql undefined
      expect(Comment.all().length).to.eql 1

  it 'dependent: destroy relations', ->
    post = Post.create()
    author = post.createAuthor()
    comment1 = post.comments().create()
    comment2 = post.comments().create()
    expect(Post.all().length).to.eql 1
    expect(Author.all().length).to.eql 1
    expect(Comment.all().length).to.eql 2
    post.destroy()
    expect(Post.all().length).to.eql 0
    expect(Author.all().length).to.eql 0
    expect(Comment.all().length).to.eql 2

  describe 'adds useful static method', ->
    it '#all', ->
      [1..10].forEach -> Post.create()
      expect(Post.all().length).to.eql 10

    it '#find', ->
      [1..10].forEach (index) -> Post.create({ id: index })
      expect(Post.find(1)).to.not.eql undefined
      expect(Post.find(15)).to.eql undefined

    it '#where', ->
      [1..10].forEach (index) -> Post.create({ id: index })
      expect(Post.where({ id: 1 }).length).to.eql 1
      expect(Post.where({ id: 20 }).length).to.eql 0

    it '#create', ->
      expect(Post.collection).to.eql []
      post = Post.create()
      expect(Post.collection).to.eql [post]

    it '#deleteAll', ->
      [1..10].forEach -> Post.create()
      expect(Post.all().length).to.eql 10
      Post.deleteAll()
      expect(Post.all().length).to.eql 0

    it '#delegate', ->
      post = Post.create()
      expect(post.saySomething()).to.eql 'post instance method called'
      author = post.createAuthor()
      expect(author.saySomething()).to.eql 'post instance method called'
      expect(author.comments().length).to.eql 0
      post.comments().create()
      expect(author.comments().length).to.eql 1
