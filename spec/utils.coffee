describe 'utils', ->
  it '#extend', ->
    expect(utils.extend({}, { a: '1' })).toEqual { a: '1' }
    expect(utils.extend({ a: '1' }, {})).toEqual { a: '1' }
    expect(utils.extend({ a: '1' }, { b: '2' })).toEqual { a: '1', b: '2' }

  it '#where', ->
    obj1 = { a: '1', d: '4' }
    obj2 = { b: '2', e: '5' }
    obj3 = { c: '3', a: '1' }
    expect(utils.where([obj1, obj2, obj3], { a: '1' })).toEqual [obj1, obj3]

  it '#filter', ->
    obj1 = { a: '1', d: '4' }
    obj2 = { a: '2', e: '5' }
    obj3 = { a: '3', c: '1' }
    obj4 = { a: '4', c: '10' }
    arr = [obj1, obj2, obj3, obj4]
    expect(utils.filter(arr, (obj) -> obj.a > 2)).toEqual [obj3, obj4]

  it '#keys', ->
    expect(utils.keys({})).toEqual []
    expect(utils.keys()).toEqual []
    expect(utils.keys({ a: '1', b: '2' })).toEqual ['a', 'b']

  it '#uniq', ->
    expect(utils.uniq([1, 1, 2, 3])).toEqual [1, 2, 3]
