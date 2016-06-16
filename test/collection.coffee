Comment = require("./comment")
Post = require("./post")
Tag = require("./tag")
PostTag = require("./post_tag")
Category = require("./category")
CategoryPost = require("./category_post")
expect = require('chai').expect

describe 'Collection', ->
  beforeEach ->
    Post.deleteAll()
    Comment.deleteAll()
    PostTag.deleteAll()
    Tag.deleteAll()

  describe 'static', ->
    describe '#create', ->
      it 'on relation', ->
        post = Post.create()
        comment = post.comments().create()
        expect(post.comments()[0]).to.deep.eq comment
        expect(comment.postId).to.eq post.id

      it 'on relation filtered by #where (without arrays)', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'another body' })
        comment = post.comments().where({ body: 'somebody' }).create()
        expect(post.comments().length).to.eq 3
        expect(comment.body).to.eq 'somebody'

      it 'on relation filtered by #where (with arrays)', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'another body' })
        comment = post.comments().where({ body: ['somebody', 'another body'] }).create()
        expect(post.comments().length).to.eq 3
        expect(comment.body).to.eq undefined

    describe '#deleteAll', ->
      it 'on relation', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'another body' })
        expect(post.comments().length).to.eq 2
        post.comments().deleteAll()
        expect(post.comments().length).to.eq 0

      it 'on relation filtered by #where', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'somebody' })
        comment3 = post.comments().create({ body: 'another body' })
        expect(post.comments().length).to.eq 3
        post.comments().where({ body: 'somebody' }).deleteAll()
        expect(post.comments().length).to.eq 1

    describe '#destroyAll', ->
      it 'on relation', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'another body' })
        expect(post.comments().length).to.eq 2
        post.comments().destroyAll()
        expect(post.comments().length).to.eq 0

      it 'on relation filtered by #where', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'somebody' })
        comment3 = post.comments().create({ body: 'another body' })
        expect(post.comments().length).to.eq 3
        post.comments().where({ body: 'somebody' }).destroyAll()
        expect(post.comments().length).to.eq 1

    describe '#where', ->
      it 'works', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'somebody' })
        comment3 = post.comments().create({ body: 'another body' })
        expect(post.comments().where({ body: 'somebody' }).length).to.eq 2

      it 'works with arrays', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'third body' })
        comment3 = post.comments().create({ body: 'another body' })
        expect(post.comments().where({ body: ['somebody', 'third body'] }).length).to.eq 2

      it 'works without args', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'third body' })
        comment3 = post.comments().create({ body: 'another body' })
        expect(post.comments().where().length).to.eq post.comments().length

      it 'on Model returns Collection instance', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'third body' })
        comment3 = post.comments().create({ body: 'another body' })
        expect(Comment.where().constructor.name).to.eq 'Collection'

      it 'on Collection instance returns Collection instance', ->
        post = Post.create()
        comment1 = post.comments().create({ body: 'somebody' })
        comment2 = post.comments().create({ body: 'third body' })
        comment3 = post.comments().create({ body: 'another body' })
        expect(post.comments().where().constructor.name).to.eq 'Collection'

    describe '#find', ->
      it 'works if OK', ->
        post = Post.create()
        [1..10].forEach (index) -> post.comments().create({ id: index })
        expect(post.comments().find(5)).to.not.eq undefined

      it 'returns undefined if not OK', ->
        post = Post.create()
        [1..10].forEach (index) -> post.comments().create({ id: index })
        expect(post.comments().find(15)).to.eq undefined

describe 'ManyToManyCollection', ->
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
        PostTag.deleteAll()
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
        PostTag.deleteAll()
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
        PostTag.deleteAll()
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
        PostTag.deleteAll()
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
        # HABTM relation not triggering callbacks
        it 'on relation', ->
          PostTag.deleteAll()
          post = Post.create()
          post.tags().create({ name: 'tag 1' })
          post.tags().create({ name: 'tag 2' })
          post.tags().create({ name: 'tag 3' })
          expect(post.tags().length).to.eq 3
          expect(PostTag.all().length).to.eq 3
          post.tags().destroyAll()
          expect(post.tags().length).to.eq 0
          expect(PostTag.all().length).to.eq 3

        it 'on relation filtered by #where', ->
          PostTag.deleteAll()
          post = Post.create()
          post.tags().create({ name: 'tag 1' })
          post.tags().create({ name: 'tag 2' })
          post.tags().create({ name: 'tag 3' })
          expect(post.tags().length).to.eq 3
          expect(PostTag.all().length).to.eq 3
          post.tags().where({ name: ['tag 1', 'tag 2'] }).destroyAll()
          expect(post.tags().length).to.eq 1
          expect(PostTag.all().length).to.eq 3

      describe '#hasMany { through }', ->
        # hasMany { through } relation triggering callbacks
        it 'on relation', ->
          CategoryPost.deleteAll()
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
          CategoryPost.deleteAll()
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
