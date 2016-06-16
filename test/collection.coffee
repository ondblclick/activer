Collection = require('../src/collection')
Comment = require("./comment")
Post = require("./post")
Tag = require("./tag")
PostTag = require("./post_tag")
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

    it '#create called on collection filtered by #where without arrays', ->
      post = Post.create()
      expect(post.comments().length).to.eql 0
      post.comments().create({ body: 'Somebody' })
      post.comments().create({ body: 'Anotherbody' })
      expect(post.comments().length).to.eql 2
      comm = post.comments().where({ body: 'Somebody' }).create()
      expect(post.comments().length).to.eql 3
      expect(comm.body).to.eq 'Somebody'

    it '#create called on collection filtered by #where with array', ->
      post = Post.create()
      expect(post.comments().length).to.eql 0
      post.comments().create({ body: 'Somebody' })
      post.comments().create({ body: 'Anotherbody' })
      expect(post.comments().length).to.eql 2
      comm = post.comments().where({ body: ['Somebody', 'Anotherbody'] }).create()
      expect(post.comments().length).to.eql 3
      expect(comm.body).to.eq undefined

    it '#create called on collection returned by hasAndBelongsToMany association', ->
      post1 = Post.create()
      post2 = Post.create()
      tag1 = Tag.create({ name: 'tag 1' })
      tag2 = Tag.create({ name: 'tag 1' })
      PostTag.create({ postId: post1.id, tagId: tag1.id })
      PostTag.create({ postId: post2.id, tagId: tag2.id })
      expect(PostTag.all().length).to.eq 2
      tag2 = post1.tags().create({ name: 'tag 2' })
      expect(PostTag.all().length).to.eq 3
      expect(post1.tags().length).to.eq 2

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

describe 'Collection', ->
  describe 'static', ->
    describe '#create', ->
    describe '#deleteAll', ->
    describe '#destroyAll', ->
    describe '#where', ->
    describe '#find', ->

describe 'ManyToManyCollection', ->
  describe 'static', ->
    describe '#create', ->
    describe '#where', ->
