noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'bug'
  c.description = 'Create an Error object'
  c.inPorts.add 'start',
    datatype: 'string'
  c.outPorts.add 'out',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'start'
    out: 'out'
    forwardGroups: true
  , (data, groups, out) ->
    if typeof data is 'string'
      err = new Error data
    else
      err = new Error 'Error'
      err.context = data
    out.send err

  c
