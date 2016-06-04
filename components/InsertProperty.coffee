noflo = require 'noflo'
_ = require 'underscore'

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

  propertyData = {}
  outputData = {}
  key = {}

  c.shutdown = ->
    propertyData = {}
    outputData = {}
    key = {}

  c.process (input, output) ->
    property = input.get 'property'
    data = input.get 'in'

    if input.ip.type is 'openBracket' and property?.data
      key[property.scope] = property.data

    if input.ip.type is 'data'
      if property?.data
        propertyData[property.scope] = property.data
      if input.ip.type is 'data' and data?.data and data instanceof Object
        outputData[data.scope] = data.data

    if input.ip.type is 'closeBracket' and property?.data
      outputData[property.scope][key[property.scope]] = propertyData[property.scope]
      output.ports.out.send outputData[property.scope]
