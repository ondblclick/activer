# activer

Base class for your JavaScript classes that adds useful `hasOne`, `hasMany` and `belongsTo` methods.

## Usage

```
import Base from 'activer'

class Author extends Base {
  static belongsTo() { return [Post] }
}

class Comment extends Base {
  static belongsTo() { return [Post] }
}

class Post extends Base {
  static hasOne() { return [Author] }
  static hasMany() { return [Comment] }
}
```

See test folder for details.
