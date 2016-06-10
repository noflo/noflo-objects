noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'splits a single object into multiple IPs,
    wrapped with the key as the group'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object to split key/values from'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Values from the input object (one value per IP and its key sent as group)'

  c.process (input, output) ->
    data = input.getData 'in'

    for key, value of data
      output.ports.out.openBracket key
      output.ports.out.data value
      output.ports.out.closeBracket()
    output.done()
