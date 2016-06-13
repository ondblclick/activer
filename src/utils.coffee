utils =
  extend: (dest, sources...) ->
    sources.forEach (object) ->
      return unless object
      for key, value of object
        dest[key] = value
    dest

  where: (arr, attrs) ->
    res = []
    arr.forEach (object) ->
      all = true
      for key, value of attrs
        all = false if object[key] isnt value
      res.push object if all
    res

  filter: (arr, predicate) ->
    res = []
    arr.forEach (object) ->
      res.push object if predicate(object)
    res

  keys: (obj) ->
    return [] unless obj
    Object.keys(obj)

  idCounter: 0

  uniqueId: (prefix) ->
    id = ++this.idCounter
    if prefix then "#{prefix + id}" else "#{id}"

  uniq: (array) ->
    output = {}
    output[array[key]] = array[key] for key in [0...array.length]
    value for key, value of output

  dfl: (str) ->
    str[0].toLowerCase() + str.slice(1)

module.exports = utils
