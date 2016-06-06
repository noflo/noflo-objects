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

  c.prepareMap = (map) ->
    return map if typeof map is 'object'
    mapParts = map.split '='
    map[mapParts[0]] = mapParts[1]
    map

  c.prepareRegExp = (map) ->
    mapParts = map.split '='
    regexps[mapParts[0]] = mapParts[1]

  c.process (input, output) ->
    # because we only want to use non-brackets
    if input.ip.type isnt 'data'
      buf = if input.scope isnt null then input.port.scopedBuffer[input.scope] else input.port.buffer
      return buf.pop()

    data = input.get 'in'
    return unless data?.type is 'data'

    map = if input.has 'map' then c.prepareMap input.getData 'map' else {}
    regexp = if input.has 'regexp' then c.prepareRegExp input.getData 'regexp' if regexp?

    newData = {}
    for property, value of data.data
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

    output.ports.sendDone out: newData
