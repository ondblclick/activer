describe 'Model', ->
  class Author extends Model
    belongsTo: -> [Post]

  class Comment extends Model
    belongsTo: -> [Post]

  class Post extends Model
    hasOne: -> [Author]
    hasMany: -> [Comment]

  beforeEach ->
    Post.collection = []
    Comment.collection = []
    Author.collection = []

  describe 'adds useful properties', ->
    it 'for class with belongsTo method implemented', ->
      post = Post.create()
      author = Author.create({ postId: post.id })
      expect(author.post()).toEqual post
      expect(author.postId).toEqual post.id

    it 'for class with hasOne method implemented', ->
      post1 = Post.create()
      post2 = Post.create()
      author1 = Author.create({ postId: post1.id })
      author2 = post2.createAuthor()
      expect(post1.author()).toEqual author1
      expect(post2.author()).toEqual author2

    it 'for class with hasMany method implemented', ->
      post = Post.create()
      comment1 = Comment.create({ postId: post.id })
      comment2 = Comment.create({ postId: post.id })
      comment3 = Comment.create()
      expect(Comment.all().length).toEqual 3
      expect(post.comments().length).toEqual 2
      expect(post.comments()[0]).toEqual comment1
      expect(post.comments()[1]).toEqual comment2
      post.comments().deleteAll()
      expect(post.comments()[0]).toBeUndefined
      expect(post.comments()[1]).toBeUndefined
      expect(Comment.all().length).toEqual 1

    it 'for collection returned by hasMany association method', ->
      post = Post.create()
      expect(post.comments().length).toEqual 0
      post.comments().create()
      expect(post.comments().length).toEqual 1

  describe 'adds useful static method', ->
    it '#all', ->
      [1..10].forEach -> Post.create()
      expect(Post.all().length).toEqual 10

    it '#find', ->
      [1..10].forEach (index) -> Post.create({ id: index })
      expect(Post.find(1)).toBeDefined()
      expect(Post.find(15)).toBeUndefined()

    it '#where', ->
      [1..10].forEach (index) -> Post.create({ id: index })
      expect(Post.where({ id: 1 }).length).toEqual 1
      expect(Post.where({ id: 20 }).length).toEqual 0

    it '#create', ->
      expect(Post.collection).toEqual []
      post = Post.create()
      expect(Post.collection).toEqual [post]

    it '#deleteAll', ->
      [1..10].forEach -> Post.create()
      expect(Post.all().length).toEqual 10
      Post.deleteAll()
      expect(Post.all().length).toEqual 0
