
noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'splits a single array into multiple IPs,
    wrapped with the key as the group'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Array to split from'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Values from the split array'

  c.process (input, output) ->
    data = input.getData 'in'

    unless typeof data is 'object' and not Array.isArray data
      for key, item of data
        output.ports.out.beginGroup key
        output.ports.out.send item
        output.ports.out.endGroup()
      output.done()
      return
    output.send out: item for item in data
    output.done()