noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'empire'

  c.inPorts.add 'in',
    datatype: 'array'
    description: 'Array to get unique values from'
  c.outPorts.add 'out',
    datatype: 'array'
    description: 'Array containing only unique values from the input array'

  noflo.helpers.WirePattern c,
    in: 'in'
    out: 'out'
    forwardGroups: true
  , (array, groups, out) ->
    seen = {}
    newArray = []
    for member in array
      seen[member] = member
    for member of seen
      newArray.push member
    out.send newArray

  c
