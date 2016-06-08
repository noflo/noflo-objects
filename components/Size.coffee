noflo = require 'noflo'
_ = require 'underscore'

exports.getComponent = ->
  c = new noflo.Component

  c.description = 'gets the size of an object and sends that out as a number'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object to measure the size of'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'int'
      description: 'Size of the input object'

  c.process (input, output) ->
    return unless input.has 'in'
    data = input.getData 'in'
    output.ports.out.data _.size data
