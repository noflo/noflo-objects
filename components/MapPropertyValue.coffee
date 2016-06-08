noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    map:
      datatype: 'all'
    regexp:
      datatype: 'string'
    in:
      datatype: 'object'
      required: true
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      required: true

  # we check the `map` for `property`
  # we check the `mapAny` for `value`
  c.process (input, output) ->
    # because we only want to use non-brackets
    return input.buffer.get().pop() if input.ip.type isnt 'data'

    return unless input.has 'in'
    data = input.getData 'in'
    mapAny = {}
    map = {}
    regexp = {}
    regexpAny = {}

    mapIn = if input.has 'map' then input.getData 'map' else {}
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

    regexIn = if input.has 'regexp' then input.getData 'regexp' else {}
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

    c.outPorts.out.data data
    c.outPorts.out.disconnect()
    output.done()
