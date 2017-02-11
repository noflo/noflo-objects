noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Insert a property into incoming objects.'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'all'
      description: 'Object to insert property into'
      required: true
    property:
      datatype: 'all'
      description: 'Property to insert (property sent as group, value sent as IP)'
      required: true

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object received as input with added properties'
  c.forwardGroups = {}
  c.process (input, output) ->
    return unless input.hasData 'in'
    return unless input.hasStream 'property'

    data = input.getData 'in'
    stream = input.getStream 'property'
    val = null
    key = null
    for ip in stream
      key = ip.data if ip.type is 'openBracket'
      val = ip.data if ip.type is 'data'
    outputData = {}
    if data instanceof Object
      outputData = data

    outputData[key] = val
    output.sendDone out: outputData
