noflo = require 'noflo'

# currently only accepts one map and one regex per object
exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    map:
      datatype: 'all'
      description: 'Map to use to map property on object'
    regexp:
      datatype: 'string'
      description: 'Regex to use to map property on object'
    in:
      datatype: 'object'
      description: 'Object to map property on'
      required: true
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      required: true

  c.process (input, output) ->
    # because we only want to use non-brackets
    return input.buffer.get().pop() if input.ip.type isnt 'data'
    return unless input.has 'in'
    data = input.getData 'in'

    regexp = {}
    if input.has 'regexp'
      regexp = input.getData 'regexp'
      regexPart = regexp.split '='
      regexps[regexPart[0]] = regexPart[1]

    map = {}
    if input.has 'map'
      map = input.getData 'map'
      if typeof map isnt 'object'
        mapParts = map.split '='
        map[mapParts[0]] = mapParts[1]

    newData = {}
    for property, value of data
      if property of map
        property = map[property]

      for expression, replacement of regexp
        regexp = new RegExp expression
        matched = regexp.exec property
        continue unless matched
        property = property.replace regexp, replacement

      if property of newData
        if Array.isArray newData[property]
          newData[property].push value
        else
          newData[property] = [newData[property], value]
      else
        newData[property] = value

    output.sendDone out: newData
