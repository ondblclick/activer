utils =
  extend: (dest, sources...) ->
    sources.forEach (object) ->
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

@utils = utils
