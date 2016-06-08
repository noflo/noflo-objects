noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    property:
      datatype: 'all'
      description: 'All except for object'
      required: true
    in:
      datatype: 'object'
      description: 'Object to set property on'
      required: true
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object forwared from input'

  c.process (input, output) ->
    # because we only want to use non-brackets
    return input.buffer.get().pop() if input.ip.type isnt 'data'
    return unless input.has 'in', 'property'

    prop = input.getData 'property'
    data = input.getData 'in'

    return unless prop? and data?

    properties = {}
    propParts = prop.split '='
    properties[propParts[0]] = propParts[1]

    for property, value of properties
      data[property] = value

    output.ports.out.data data
