utils =
  extend: (dest, sources...) ->
    sources.forEach (object) ->
      for key, value of object
        dest[key] = value
    dest

  where: (arr, attrs) ->
    res = []
    arr.forEach (object) ->
      for key, value of attrs
        res.push object if object[key] is value
    res

  keys: (obj) ->
    return [] unless obj
    Object.keys(obj)

  indexOf: (array, item) -> array.indexOf(item)

  idCounter: 0

  uniqueId: (prefix) ->
    id = ++this.idCounter
    if prefix then "#{prefix + id}" else "#{id}"

  uniq: (array) ->
    output = {}
    output[array[key]] = array[key] for key in [0...array.length]
    value for key, value of output

@utils = utils
