noflo = require('noflo')
_ = require('underscore')

exports.getComponent = ->
  key = null

  c = new noflo.Component
  c.description = 'Insert a property into incoming objects.'

  c.inPorts.add 'in',
    datatype: 'object'
    description: 'Object to insert property into'
  c.inPorts.add 'property',
    datatype: 'all'
    description: 'Property to insert (property sent as group, value sent as IP)'
    required: true

  c.outPorts.add 'out',
    datatype: 'object'
    description: 'Object received as input with added properties'

  # properties callbacks.
  c.inPorts.property.on 'begingroup', (group) ->
    key = group

  # Use the WirePattern.
  noflo.helpers.WirePattern c,
    in: ['in']
    params: ['property']
    out: ['out']
    forwardGroups: false
  ,
  (data, groups, out) ->
    data = {} unless data instanceof Object
    data[key] = c.params.property
    out.send data

  return c
