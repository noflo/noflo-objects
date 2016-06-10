noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'empire'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'array'
      description: 'Array to get unique values from'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'array'
      description: 'Array containing only unique values from the input array'

  c.process (input, output) ->
    data = input.getData 'in'

    seen = {}
    newArray = []
    for member in data
      seen[member] = member
    for member of seen
      newArray.push member
    output.sendDone newArray
