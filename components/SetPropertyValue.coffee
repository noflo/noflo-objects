noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'edit'
  c.description = 'Set a value to an object\'s property'

  c.inPorts.add 'property',
    datatype: 'string'
    description: 'Property name to set value on'
  c.inPorts.add 'value',
    datatype: 'all'
    description: 'Property value to set'
  c.inPorts.add 'in',
    datatype: 'object'
    description: 'Object to set property value on'
  c.inPorts.add 'keep',
    datatype: 'boolean'
    description: 'true if input value must be kept around, false to drop it after the value is set'

  c.outPorts.add 'out',
    datatype: 'object'
    description: 'Object forwarded from the input'

  noflo.helpers.WirePattern c,
    in: 'in'
    params: ['keep', 'property', 'value']
    out: 'out'
    forwardGroups: 'in'
    async: true
  , (obj, groups, out, callback) ->
    {property, value, keep} = c.params
    c.obj = obj
    obj[property] = value if property or value
    out.send obj
    delete c.obj unless keep
    do callback

  c
