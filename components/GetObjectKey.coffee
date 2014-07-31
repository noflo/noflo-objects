noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'indent'
  c.description = 'Get a property from an object'
  c.inPorts.add 'in',
    datatype: 'object'
    description: 'Object to get keys from'
    required: true
  c.inPorts.add 'key',
    datatype: 'string'
    description: 'Keys to extract from the object (one key per IP)'
    required: true
  c.inPorts.add 'sendgroup',
    datatype: 'boolean'
    description: 'true to send keys as groups around value IPs, false otherwise'
    required: false
  c.outPorts.add 'out',
    datatype: 'all'
    description: 'Values extracts from the input object given the input keys (one value per IP, potentially grouped using the key names)'
    required: true
  c.outPorts.add 'object',
    datatype: 'object'
    description: 'Object forwarded from input if at least one property matches the input keys'
    required: false
  c.outPorts.add 'missed',
    datatype: 'object'
    description: 'Object forwarded from input if no property matches the input keys'
    required: false

  noflo.helpers.WirePattern c,
    in: 'in'
    params: ['key', 'sendgroup']
    out: ['out', 'object']
    error: 'missed'
    forwardGroups: true
  , (data, groups, outs) ->
    if data is null
      return c.error new Error 'Data is NULL'
    unless typeof data is 'object'
      return c.error new Error 'Data is not an object'
    if data[c.params.key] is undefined
      return c.error new Error "Object has no key #{c.params.key}"

    outs.out.beginGroup c.params.key if String(c.params.sendgroup) is 'true'
    outs.out.send data[c.params.key]
    outs.out.endGroup() if String(c.params.sendgroup) is 'true'

    outs.object.send data

  c
