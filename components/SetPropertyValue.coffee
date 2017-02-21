noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    property:
      datatype: 'string'
      description: 'Property name to set value on'
      required: true
    value:
      datatype: 'all'
      description: 'Property value to set'
      required: true
    in:
      datatype: 'object'
      description: 'Object to set property value on'
      required: true
    # Persist value
    # keep:
    #   datatype: 'boolean'
    #   description: 'true if input value must be kept around, false to drop it after the value is set'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object forwarded from the input'

  c.process (input, output) ->
    return unless input.hasData 'property', 'value', 'in'

    data = input.getData 'in'
    property = input.getData 'property'
    value = input.getData 'value'
    data[property] = value
    output.sendDone out: data
