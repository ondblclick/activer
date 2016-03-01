describe 'Model', ->
  class Author extends Model
    belongsTo: -> [Post]

  class Comment extends Model
    belongsTo: -> [Post]

  class Post extends Model
    hasOne: -> [Author]
    hasMany: -> [Comment]

  describe 'adds useful properties', ->
    it 'for class with belongsTo method implemented', ->
      post = Post.create()
      author = Author.create({ post_id: post.id })
      expect(author.post()).toEqual post
      expect(author.post_id).toEqual post.id

    it 'for class with hasOne method implemented', ->
      post1 = Post.create()
      post2 = Post.create()
      author1 = Author.create({ post_id: post1.id })
      author2 = post2.createAuthor()
      expect(post1.author()).toEqual author1
      expect(post2.author()).toEqual author2

    it 'for class with hasMany method implemented', ->
      post = Post.create()
      comment1 = Comment.create({ post_id: post.id })
      comment2 = Comment.create({ post_id: post.id })
      comment3 = Comment.create()
      expect(Comment.all().length).toEqual 3
      expect(post.comments().length).toEqual 2
      expect(post.comments()[0]).toEqual comment1
      expect(post.comments()[1]).toEqual comment2
      post.comments().deleteAll()
      expect(post.comments()[0]).toEqual undefined
      expect(post.comments()[1]).toEqual undefined
      expect(Comment.all().length).toEqual 1

    it 'for collection returned by hasMany association method', ->
      post = Post.create()
      expect(post.comments().length).toEqual 0
      post.comments().create()
      expect(post.comments().length).toEqual 1
