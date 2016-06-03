noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    icon: 'filter'
    description: 'Filter out some values'
  c.accepts = {}
  c.regexps = {}

  c.inPorts = new noflo.InPorts
    accept:
      datatype: 'all'
      description: ''
    regexp:
      datatype: 'string'
      description: ''
    in:
      datatype: 'object'
      description: 'Object to filter properties from'

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object including the filtered properties'
    missed:
      datatype: 'object'
      description: 'Object received as input if no key have been matched'

  c.filtering = ->
    return ((Object.keys c.accepts).length > 0 or
        (Object.keys c.regexps).length > 0)

  c.prepareAccept = (map) ->
    if typeof map is 'object'
      c.accepts = map
      return

    mapParts = map.split '='
    try
      c.accepts[mapParts[0]] = eval mapParts[1]
    catch e
      if e instanceof ReferenceError
        c.accepts[mapParts[0]] = mapParts[1]
      else throw e

  c.prepareRegExp = (map) ->
    mapParts = map.split '='
    c.regexps[mapParts[0]] = mapParts[1]

  c.filterData = (object) ->
    newData = {}
    match = false
    for property, value of object
      if c.accepts[property]
        continue unless c.accepts[property] is value
        match = true

      if c.regexps[property]
        regexp = new RegExp c.regexps[property]
        continue unless regexp.exec value
        match = true

      newData[property] = value
      continue

    unless match
      return unless c.outPorts.missed.isAttached()
      c.outPorts.missed.send object
      c.outPorts.missed.disconnect()
      return

    c.outPorts.out.send newData

  c.process (input, output) ->
    return unless input.ip.type is 'data'

    if input.has 'accept'
      accept = input.getData 'accept'
      c.prepareAccept accept if accept?

    if input.has 'regexp'
      regexp = input.getData 'regexp'
      c.prepareRegExp regexp if regexp?

    if input.has 'in'
      data = input.getData 'in'
      return c.filterData data if c.filtering()
      c.outPorts.out.send data

