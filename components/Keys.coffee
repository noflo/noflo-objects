noflo = require 'noflo'
_ = require 'underscore'

exports.getComponent = ->
  c = new noflo.Component

  c.description = 'gets only the keys of an object and forward them as an array'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object to get keys from'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'string'
      description: 'Keys from the incoming object (one per IP)'

  c.process (input, output) ->
    return unless input.has 'in'
    data = input.getData 'in'
    c.outPorts.out.send key for key in _.keys data
