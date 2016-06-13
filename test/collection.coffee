Collection = require('../src/collection')
Comment = require("./comment")
Post = require("./post")
expect = require('chai').expect

describe 'Collection', ->
  beforeEach ->
    Post.deleteAll()
    Comment.deleteAll()

  describe 'is returned', ->
    it 'for Model instance #where call', ->
      post = Post.create()
      post.comments().create({ body: 'Some comment body' })
      expect(Comment.where({ body: 'Some comment body' }).constructor.name).to.eql 'Collection'

    it 'for Model instance #all call', ->
      post = Post.create()
      post.comments().create()
      expect(Comment.all().constructor.name).to.eql 'Collection'

    it 'for Collection instance #where call', ->
      post = Post.create()
      post.comments().create({ body: 'Some comment body' })
      expect(post.comments().where({ body: 'Some comment body' }).constructor.name).to.eql 'Collection'
      expect(Comment.all().where({ body: 'Some comment body' }).constructor.name).to.eql 'Collection'

  describe 'returns proper value', ->
    it 'for hasMany relation', ->
      post = Post.create()
      comment1 = post.comments().create()
      expect(post.comments().length).to.eql 1
      expect(post.comments()[0]).to.deep.eql comment1

    it 'for #where method called on Model', ->
      post = Post.create()
      expect(Post.where({ id: post.id })[0]).to.deep.eql post

    it 'for #all method called on Model', ->
      post = Post.create()
      expect(Post.all()[0]).to.deep.eql post

    it 'for #where method called on Collection', ->
      post1 = Post.create({ name: 'Some name', description: 'Some description' })
      post2 = Post.create({ name: 'Another name', description: 'Some description' })
      expect(Post.where({ description: 'Some description' }).length).to.eql 2
      expect(Post.where({ description: 'Some description' }).where({ name: 'Some name' }).length).to.eql 1
      expect(Post.where({ description: 'Some description' }).where({ name: 'Some name' })[0]).to.deep.eql post1
      expect(Post.all().length).to.eql 2
      expect(Post.all().where({ description: 'Some description' }).where({ name: 'Some name' }).length).to.eql 1
      expect(Post.all().where({ description: 'Some description' }).where({ name: 'Some name' })[0]).to.deep.eql post1
      expect(Post.all().where().where().where().length).to.eql 2

  describe 'has method', ->
    it '#create', ->
      post = Post.create()
      expect(post.comments().length).to.eql 0
      post.comments().create()
      expect(post.comments().length).to.eql 1

    it '#deleteAll', ->
      post = Post.create()
      post.comments().create({ id: 1 })
      expect(post.comments().length).to.eql 1
      post.comments().deleteAll()
      expect(post.comments().length).to.eql 0

    it '#where', ->
      post = Post.create()
      comment = post.comments().create({ id: 1 })
      expect(post.comments().where({ id: 1 }).length).to.eql 1

    it '#find', ->
      post = Post.create()
      comment = post.comments().create({ id: 1 })
      expect(post.comments().find(1)).to.deep.eql comment
