# activer

Base class for your JavaScript classes that adds useful `hasOne`, `hasMany` and `belongsTo` methods.

## Usage

in your user.js:
```
import Model from 'activer';
import Post from './post'

class User extends Model {
  saySomething() { console.log('User'); }
}

User.attrs('name', 'description');
User.hasOne('Post');

export default User
```

in your comment.js:
```
import Model from 'activer';
import Post from './post';

class Comment extends Model {
  saySomething() { console.log('Comment'); }
}

Comment.attrs('name', 'description');
Comment.belongsTo('Post');

export default Comment
```

in your post.js:
```
import Model from 'activer';
import User from './user';
import Comment from './comment';

class Post extends Model {
  saySomething() { console.log('Post'); }
}

Post.attrs('name', 'description');
Post.belongsTo('User');
Post.hasMany('Comment');

export default Post
```

in your main.js:
```
import User from './user';

var user = User.create({ name: "User name", description: "User description" });
var post = user.createPost({ name: "Post name", description: "Post description" });
var comment1 = post.comments().create({ name: "Comment 1 name", description: "Comment 1 description" });
var comment2 = post.comments().create({ name: "Comment 2 name", description: "Comment 2 description" });

console.log(user.post().comments().length); // returns 2
```

See tests for details.
