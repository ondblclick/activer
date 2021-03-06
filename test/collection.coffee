Comment = require("./comment")
Post = require("./post")
expect = require('chai').expect

describe 'Collection', ->
  beforeEach ->
    Post.deleteAll()
    Comment.deleteAll()

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
