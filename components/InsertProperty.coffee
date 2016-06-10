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

  c.process (input, output) ->
    openBracket = (input.buffer.find 'property', (ip) -> ip.type is 'openBracket' and ip.data?)[0]
    propData = (input.buffer.find 'property', (ip) -> ip.type is 'data' and ip.data?)[0]
    closeBracket = (input.buffer.find 'property', (ip) -> ip.type is 'closeBracket' and ip.data?)[0]
    hasData = input.has 'in', (ip) -> ip.type is 'data'

    return unless openBracket? and propData? and closeBracket? and hasData
    data = input.getData 'in'
    key = openBracket.data
    outputData = {}
    if data instanceof Object
      outputData = data

    outputData[key] = propData.data
    input.buffer.set 'property', []
    output.sendDone out: outputData
