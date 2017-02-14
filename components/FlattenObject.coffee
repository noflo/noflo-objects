noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    map:
      datatype: 'all'
      description: 'map to use to flatten the object'
      control: true
    in:
      datatype: 'object'
      description: 'Object to flatten'
      required: true

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'array'

  mapKeys = (object, maps) ->
    for key, map of maps
      object[map] = object.flattenedKeys[key]
    delete object.flattenedKeys
    return object

  flattenObject = (object) ->
    flattened = []
    for key, value of object
      if typeof value is 'object'
        flattenedValue = flattenObject value
        for val in flattenedValue
          val.flattenedKeys.push key
          flattened.push val
        continue

      flattened.push
        flattenedKeys: [key]
        value: value
    flattened

  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasData 'in'
    return unless input.hasData 'map' if input.attached('map').length > 0
    maps = {}

    if input.hasData 'map'
      map = input.getData 'map'
      if map?
        if typeof map is 'object'
          maps = map
        else
          mapParts = map.split '='
          maps[mapParts[0]] = mapParts[1]

    data = input.getData 'in'
    output.send new noflo.IP 'openBracket'
    for object in flattenObject data
      output.send mapKeys object, maps
    output.send new noflo.IP 'closeBracket'
    output.done()
