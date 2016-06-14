# activer

[![Build Status](https://travis-ci.org/ondblclick/activer.svg?branch=master)](https://travis-ci.org/ondblclick/activer)

Base class for your JavaScript models that adds useful `hasOne`, `hasMany`, `belongsTo`, `attributes` and `delegate` static methods (as well as `save`, `update` and `destroy` instance methods and a few callbacks).

## Usage

in your `user.js`:
```javascript
import Model from 'activer';
import Post from './post'

class User extends Model {
  sayAnotherThing() { console.log('User'); }
}

User.attributes('name', 'description');
User.hasOne('Post');
User.delegate('saySomething', 'Post');

export default User
```

in your `comment.js`:
```javascript
import Model from 'activer';
import Post from './post';

class Comment extends Model {
  saySomething() { console.log('Comment'); }
}

Comment.attributes('name', 'description');
Comment.belongsTo('Post');

export default Comment
```

in your `post.js`:
```javascript
import Model from 'activer';
import User from './user';
import Comment from './comment';

class Post extends Model {
  saySomething() { console.log('Post'); }
}

Post.attributes('name', 'description');
Post.belongsTo('User');
Post.hasMany('Comment', { dependent: 'destroy' });

export default Post
```

in your `main.js`:
```javascript
import User from './user';
import Comment from './comment';

var user = User.create({ name: "User name", description: "User description" });
var post = user.createPost({ name: "Post name", description: "Post description" });
var comment1 = post.comments().create({ name: "Comment 1 name", description: "Comment 1 description" });
var comment2 = post.comments().create({ name: "Comment 2 name", description: "Comment 2 description" });

user.saySomething(); // 'Post'
console.log(user.post().comments().length); // 2
console.log(Comment.all().length); // 2
console.log(user.post().comments()[0].name); // "Comment 1 name"
user.post().destroy();
console.log(Comment.all().length); // 0
console.log(user.post()); // undefined
```

See tests for details.

## Store

Activer uses in-memory storage by default but you can specify your own data access object to use whatewer you want using the static `collection` method. DAO should implement some methods:

```javascript
dataAccessObject = {
  create(props) { /**/ }
  update(id, props) { /**/ }
  remove(id) { /**/ }
  removeAll(props) { /**/ }
  get(id) { /**/ }
  getAll(props) { /**/ }
}

class User extends Model {}
User.collection(dataAccessObject)
```

See default implementation in `src/dao.coffee`.

## Changelog

0.10.0: Model static methods `all` and `where` now return Collection instance. Collection instance method `where` now returns new Collection instance. One can do `User.all().where({ something: 'something' }).where({ anotherThing: 'Another thing' }).deleteAll()` now.
