noflo = require 'noflo'

# currently only supports one map and regex per object
exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    map:
      datatype: 'all'
      description: 'Map to use to map property value on object'
    regexp:
      datatype: 'string'
      description: 'Regex to use to map property value on object'
    in:
      datatype: 'object'
      description: 'Object to map property value on'
      required: true
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      required: true

  c.process (input, output) ->
    return unless input.hasData 'in'
    return unless input.hasData 'regexp' if input.attached('regexp').length > 0
    return unless input.hasData 'map' if input.attached('map').length > 0

    data = input.getData 'in'
    mapAny = {}
    map = {}
    regexp = {}
    regexpAny = {}

    mapIn = if input.hasData 'map' then input.getData 'map' else {}
    # if it is not an object, process it...
    if typeof mapIn isnt 'object'
      mapParts = mapIn.split '='
      if mapParts.length is 3
        map[mapParts[0]] =
          from: mapParts[1]
          to: mapParts[2]
      else
        mapAny[mapParts[0]] = mapParts[1]
    # ...otherwise we keep it as an object
    else
      mapAny = mapIn

    regexIn = if input.hasData 'regexp' then input.getData 'regexp' else {}
    if typeof regexIn isnt 'object'
      regexParts = regexIn.split '='
      if regexParts.length is 3
        regexp[regexParts[0]] =
          from: regexParts[1]
          to: regexParts[2]
      regexpAny[regexParts[0]] = regexParts[1]

    for property, value of data
      # map stuff
      if map[property] and map[property].from is value
        data[property] = map[property].to

      if mapAny[value]
        data[property] = mapAny[value]

      # regex stuff
      if regexp[property]
        regexp = new RegExp regexp[property].from
        matched = regexp.exec value
        if matched
          data[property] = value.replace regexp, c.regexp[property].to

      for expression, replacement of c.regexpAny
        regexp = new RegExp expression
        matched = regexp.exec value
        continue unless matched
        data[property] = value.replace regexp, replacement

    output.sendDone out: data
