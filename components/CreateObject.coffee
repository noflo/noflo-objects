noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Create a new empty object'

  c.inPorts.add 'start',
    datatype: 'bang'
    description: 'Signal to create a new object'

  c.outPorts.add 'out',
    datatype: 'object'
    description: 'A new empty object'

  noflo.helpers.WirePattern c,
    in: 'start'
    out: 'out'
    forwardGroups: true
    async: true
  , (payload, groups, out, callback) ->
    out.send {}
    do callback

  c
