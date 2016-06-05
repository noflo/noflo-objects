noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.properties = {}

  c.inPorts = new noflo.InPorts
    property:
      datatype: 'all'
    in:
      datatype: 'object'
      description: 'Object to set property on'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object forwared from input'

  c.process (input, output) ->
    propBuffer = input.ports.property.buffer
    inBuffer = input.ports.in.buffer
    prop = (propBuffer.filter (ip) -> ip.type is 'data' and ip.data?)[0]
    data = (inBuffer.filter (ip) -> ip.type is 'data' and ip.data?)[0]

    return unless prop? and data?
    prop = prop.data
    data = data.data
    properties = {}

    # why does it need this?
    if typeof prop is 'object'
      c.prop = prop
      return

    propParts = prop.split '='
    properties[propParts[0]] = propParts[1]

    for property, value of properties
      data[property] = value

    output.ports.out.send data
