noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    map:
      datatype: 'all'
    in:
      datatype: 'object'
      description: 'Object to flatten'

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'array'

  c.map = {}

  c.prepareMap = (map) ->
    if typeof map is 'object'
      c.map = map
      return
    mapParts = map.split '='
    c.map[mapParts[0]] = mapParts[1]

  c.mapKeys = (object) ->
    for key, map of c.map
      object[map] = object.flattenedKeys[key]
    delete object.flattenedKeys
    return object

  c.flattenObject = (object) ->
    flattened = []
    for key, value of object
      if typeof value is 'object'
        flattenedValue = c.flattenObject value
        for val in flattenedValue
          val.flattenedKeys.push key
          flattened.push val
        continue

      flattened.push
        flattenedKeys: [key]
        value: value

    return flattened

  c.process (input, output) ->
    return unless input.ip.type is 'data'

    if input.has 'map'
      map = input.getData 'map'
      c.prepareMap map if map?

    if input.has 'in'
      data = input.getData 'in'
      for object in c.flattenObject data
        c.outPorts.out.send c.mapKeys object

      c.outPorts.out.disconnect()
      output.done()
      c.map = {}

