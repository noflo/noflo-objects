noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Create an empty object'

  c.inPorts = new noflo.InPorts
    start:
      datatype: 'bang'
      description: 'Signal to create a new object'

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'A new empty object'

  c.process (input, output) ->
    return unless input.has 'in'
    return unless input.ip.type is 'data'
    output.sendDone out: {}
