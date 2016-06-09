noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    icon: 'filter'
    description: 'Filter out some values'

  c.inPorts = new noflo.InPorts
    accept:
      datatype: 'all'
      description: 'property value to accept, can be more than one per object'
    regexp:
      datatype: 'string'
      description: 'regex properties to accept'
    in:
      datatype: 'object'
      description: 'Object to filter properties from'
      required: true

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object including the filtered properties'
    missed:
      datatype: 'object'
      description: 'Object received as input if no key have been matched'

  c.filterData = (object, accepts, regexps) ->
    newData = {}
    match = false
    for property, value of object
      if accepts[property]
        continue unless accepts[property] is value
        match = true

      if regexps[property]
        regexp = new RegExp regexps[property]
        continue unless regexp.exec value
        match = true

      newData[property] = value
      continue

    unless match
      return unless c.outPorts.missed.isAttached()
      c.outPorts.missed.data object
      c.outPorts.missed.disconnect()
      return

    c.outPorts.out.data newData

  c.process (input, output) ->
    return unless input.ip.type is 'data'
    regexps = {}
    accepts = {}
    if input.has 'accept'
      acceptData = input.buffer
        .find 'accept', (ip) -> ip.type is 'data'
        .map (ip) -> ip.data

      for accept, index in acceptData
        if typeof accept is 'object'
          accepts = accept
          break
        mapParts = accept.split '='
        try
          accepts[mapParts[0]] = eval mapParts[1]
        catch e
          if e instanceof ReferenceError
            accepts[mapParts[0]] = mapParts[1]
          else throw e

    if input.has 'regexp'
      regexpData = input.buffer
        .find 'regexp', (ip) -> ip.type is 'data'
        .map (ip) -> ip.data
      if regexpData.length > 0
        mapParts = regexpData[0].split '='
        regexps[mapParts[0]] = mapParts[1]

    if input.has 'in'
      data = input.get('in').data

      if ((Object.keys accepts).length > 0 or (Object.keys regexps).length > 0)
        return c.filterData data, accepts, regexps
      c.outPorts.out.data data
