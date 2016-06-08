noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'clock-o'
  c.description = 'Send out the current timestamp'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'bang'
      description: 'Causes the current timestamp to be sent out'

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'int'

  c.process (input, output) ->
    return unless input.ip.type is 'data'
    output.sendDone out: Date.now()
