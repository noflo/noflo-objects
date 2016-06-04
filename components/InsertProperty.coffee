noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Insert a property into incoming objects.'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'all'
      description: 'Object to insert property into'
    property:
      datatype: 'all'
      description: 'Property to insert (property sent as group, value sent as IP)'
      required: true

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object received as input with added properties'

  c.process (input, output) ->
    propBuffer = input.ports.property.buffer
    openBracket = (propBuffer.filter (ip) -> ip.type is 'openBracket' and ip.data?)[0]
    propData = (propBuffer.filter (ip) -> ip.type is 'data' and ip.data?)[0]
    closeBracket = (propBuffer.filter (ip) -> ip.type is 'closeBracket' and ip.data?)[0]
    hasData = input.has 'in'

    return unless openBracket? and propData? and closeBracket? and hasData
    data = input.getData 'in'
    key = openBracket.data

    outputData = {}
    if data instanceof Object
      outputData = data

    outputData[key] = propData.data
    output.ports.out.send outputData
