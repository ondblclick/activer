Comment = require("./comment")
Post = require("./post")
Tag = require("./tag")
PostTag = require("./post_tag")
Category = require("./category")
CategoryPost = require("./category_post")
expect = require('chai').expect

describe 'ManyToManyCollection', ->
  beforeEach ->
    Post.deleteAll()
    Comment.deleteAll()
    PostTag.deleteAll()
    Tag.deleteAll()
    CategoryPost.deleteAll()

  describe 'static', ->
    describe '#create', ->
      it 'on relation', ->
        post = Post.create()
        expect(post.tags().length).to.eq 0
        expect(PostTag.all().length).to.eq 0
        post.tags().create()
        expect(post.tags().length).to.eq 1
        expect(PostTag.all().length).to.eq 1

      it 'on relation filtered by #where (without arrays)', ->
        post = Post.create()
        post.tags().create({ name: 'tag 1' })
        post.tags().create({ name: 'tag 2' })
        post.tags().create({ name: 'tag 3' })
        expect(post.tags().length).to.eq 3
        expect(PostTag.all().length).to.eq 3
        tag = post.tags().where({ name: 'tag 3' }).create()
        expect(post.tags().length).to.eq 4
        expect(PostTag.all().length).to.eq 4
        expect(tag.name).to.eq 'tag 3'

      it 'on relation filtered by #where (with arrays)', ->
        post = Post.create()
        post.tags().create({ name: 'tag 1' })
        post.tags().create({ name: 'tag 2' })
        post.tags().create({ name: 'tag 3' })
        expect(post.tags().length).to.eq 3
        expect(PostTag.all().length).to.eq 3
        tag = post.tags().where({ name: ['tag 1', 'tag 2'] }).create()
        expect(post.tags().length).to.eq 4
        expect(PostTag.all().length).to.eq 4
        expect(tag.name).to.eq undefined

    describe '#deleteAll', ->
      it 'on relation', ->
        post = Post.create()
        post.tags().create({ name: 'tag 1' })
        post.tags().create({ name: 'tag 2' })
        post.tags().create({ name: 'tag 3' })
        expect(post.tags().length).to.eq 3
        expect(PostTag.all().length).to.eq 3
        post.tags().deleteAll()
        expect(post.tags().length).to.eq 0
        expect(PostTag.all().length).to.eq 3

      it 'on relation filtered by #where', ->
        post = Post.create()
        post.tags().create({ name: 'tag 1' })
        post.tags().create({ name: 'tag 2' })
        post.tags().create({ name: 'tag 3' })
        expect(post.tags().length).to.eq 3
        expect(PostTag.all().length).to.eq 3
        post.tags().where({ name: ['tag 1', 'tag 2'] }).deleteAll()
        expect(post.tags().length).to.eq 1
        expect(PostTag.all().length).to.eq 3

    describe '#destroyAll', ->
      describe '#hasAndBelongsToMany', ->
        it 'on relation', ->
          post = Post.create()
          post.tags().create({ name: 'tag 1' })
          post.tags().create({ name: 'tag 2' })
          post.tags().create({ name: 'tag 3' })
          expect(post.tags().length).to.eq 3
          expect(PostTag.all().length).to.eq 3
          post.tags().destroyAll()
          expect(post.tags().length).to.eq 0
          expect(PostTag.all().length).to.eq 0

        it 'on relation filtered by #where', ->
          post = Post.create()
          post.tags().create({ name: 'tag 1' })
          post.tags().create({ name: 'tag 2' })
          post.tags().create({ name: 'tag 3' })
          expect(post.tags().length).to.eq 3
          expect(PostTag.all().length).to.eq 3
          post.tags().where({ name: ['tag 1', 'tag 2'] }).destroyAll()
          expect(post.tags().length).to.eq 1
          expect(PostTag.all().length).to.eq 1

      describe '#hasMany { through }', ->
        it 'on relation', ->
          post = Post.create()
          post.categorys().create({ name: 'category 1' })
          post.categorys().create({ name: 'category 2' })
          post.categorys().create({ name: 'category 3' })
          expect(post.categorys().length).to.eq 3
          expect(CategoryPost.all().length).to.eq 3
          post.categorys().destroyAll()
          expect(post.categorys().length).to.eq 0
          expect(CategoryPost.all().length).to.eq 0

        it 'on relation filtered by #where', ->
          post = Post.create()
          post.categorys().create({ name: 'category 1' })
          post.categorys().create({ name: 'category 2' })
          post.categorys().create({ name: 'category 3' })
          expect(post.categorys().length).to.eq 3
          expect(CategoryPost.all().length).to.eq 3
          post.categorys().where({ name: ['category 1', 'category 2'] }).destroyAll()
          expect(post.categorys().length).to.eq 1
          expect(CategoryPost.all().length).to.eq 1

    describe '#where', ->
      it 'works', ->
        post = Post.create()
        post.categorys().create({ name: 'category 1' })
        post.categorys().create({ name: 'category 1' })
        post.categorys().create({ name: 'category 3' })
        expect(post.categorys().where({ name: 'category 1' }).length).to.eq 2

      it 'works with arrays', ->
        post = Post.create()
        post.categorys().create({ name: 'category 1' })
        post.categorys().create({ name: 'category 2' })
        post.categorys().create({ name: 'category 3' })
        expect(post.categorys().where({ name: ['category 1', 'category 2'] }).length).to.eq 2

      it 'works without args', ->
        post = Post.create()
        post.categorys().create({ name: 'category 1' })
        post.categorys().create({ name: 'category 2' })
        post.categorys().create({ name: 'category 3' })
        expect(post.categorys().where().length).to.eq post.categorys().length

      it 'on ManyToManyCollection instance returns ManyToManyCollection instance', ->
        post = Post.create()
        post.categorys().create({ name: 'category 1' })
        post.categorys().create({ name: 'category 2' })
        post.categorys().create({ name: 'category 3' })
        expect(post.categorys().where().constructor.name).to.eq 'ManyToManyCollection'
