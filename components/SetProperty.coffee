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
    return unless input.hasData 'in', 'property'

    prop = input.getData 'property'
    data = input.getData 'in'

    properties = {}
    propParts = prop.split '='
    properties[propParts[0]] = propParts[1]

    for property, value of properties
      data[property] = value

    output.sendDone data
