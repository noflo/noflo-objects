noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Create a new Date object from string'
    icon: 'clock-o'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'string'
      description: 'A string representation of a date in RFC2822/IETF/ISO8601 format'

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'A new Date object'

  c.process (input, output) ->
    return unless input.has 'in'
    data = input.getData 'in'

    if data is 'now' or data is null or data is true
      date = new Date
    else
      date = new Date data
    c.outPorts.out.send date
