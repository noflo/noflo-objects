noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.description = 'gets only the values of an object and forward them as an array'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'all'
      description: 'Object to extract values from'

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Values extracted from the input object (one value per IP)'

  c.process (input, output) ->
    data = input.getData 'in'
    return unless data?

    keys = Object.keys data
    values = Array(keys.length)
    for key, index in keys
      values[index] = data[key]

    output.ports.out.data value for value in values
