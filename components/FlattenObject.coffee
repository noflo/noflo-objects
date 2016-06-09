noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    map:
      datatype: 'all'
      description: 'map to use to flatten the object'
    in:
      datatype: 'object'
      description: 'Object to flatten'
      required: true

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'array'

  c.mapKeys = (object, maps) ->
    for key, map of maps
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
    flattened

  c.process (input, output) ->
    maps = {}
    if (input.has 'map', (ip) -> ip.type is 'data')
      map = (input.buffer
        .find 'map', (ip) -> ip.type is 'data'
        .map (ip) -> ip.data)[0]

      if map?
        if typeof map is 'object'
          maps = map
        else
          mapParts = map.split '='
          map[mapParts[0]] = mapParts[1]

    if (input.has 'in', (ip) -> ip.type is 'data')
      data = input.getData 'in'
      for object in c.flattenObject data
        c.outPorts.out.send c.mapKeys object, maps
      c.outPorts.out.disconnect()
      output.done()

    if (input.has 'in', (ip) -> ip.type is 'openBracket')
      input.buffer.set 'map', []

