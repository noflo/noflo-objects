noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    property:
      datatype: 'string'
      description: 'Pro perty name to set value on'
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
    keep:
      datatype: 'boolean'
      description: 'true if input value must be kept around, false to drop it after the value is set'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object forwarded from the input'

  c.process (input, output) ->
    input.buffer.get().pop() if input.ip.type isnt 'data'
    return unless input.has 'property', 'value', 'in', (ip) -> ip.type is 'data'
    data = (input.buffer.find 'in', (ip) -> ip.data isnt undefined)[0].data
    property = (input.buffer.find 'property', (ip) -> ip.data isnt undefined)[0].data
    value = (input.buffer.find 'value', (ip) -> ip.data isnt undefined)[0].data
    data[property] = value
    output.sendDone out: data
    input.buffer.set 'property', []
    input.buffer.set 'value', []
    input.buffer.set 'in', []