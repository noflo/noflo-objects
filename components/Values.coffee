noflo = require 'noflo'
_ = require 'underscore'

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
    return unless input.has 'in'
    data = input.getData 'in'
    output.ports.out.send value for value in _.values data
