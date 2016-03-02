describe 'Collection', ->
  class Comment extends Model
    @belongsTo: -> [Post]

  class Post extends Model
    @hasMany: -> [Comment]

  describe 'adds useful properties', ->
    describe 'for collection returned by hasMany association', ->
      beforeEach ->
        Post.deleteAll()
        Comment.deleteAll()

      it '#create', ->
        post = Post.create()
        expect(post.comments().length).toEqual 0
        post.comments().create()
        expect(post.comments().length).toEqual 1

      it '#deleteAll', ->
        post = Post.create()
        post.comments().create({ id: 1 })
        expect(post.comments().length).toEqual 1
        post.comments().deleteAll()
        expect(post.comments().length).toEqual 0

      it '#where', ->
        post = Post.create()
        comment = post.comments().create({ id: 1 })
        expect(post.comments().where({ id: 1 })).toEqual [comment]

      it '#find', ->
        post = Post.create()
        comment = post.comments().create({ id: 1 })
        expect(post.comments().find(1)).toEqual comment
