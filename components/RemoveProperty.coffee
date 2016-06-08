noflo = require 'noflo'
_ = require 'underscore'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'ban'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object to remove properties from'
    property:
      datatype: 'string'
      description: 'Properties to remove (one per IP)'

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object forwarded from input'

  c.process (input, output) ->
    propData = input.ports.property.buffer.filter (ip) -> ip.type is 'data' and ip.data?
    return unless propData? and input.has 'in'
    data = input.getData 'in'

    # Clone the object so that the original isn't changed
    object = _.clone data

    for property in propData
      delete object[property.data]

    output.ports.out.data object
