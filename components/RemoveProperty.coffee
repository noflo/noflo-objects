noflo = require 'noflo'

clone = (obj) ->
  return obj if obj is null or typeof obj isnt 'object'
  temp = new obj.constructor()
  for key of obj
    temp[key] = clone obj[key]
  temp

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
    propData = input.buffer.find 'property', (ip) -> ip.type is 'data' and ip.data?
    return unless propData? and (input.has 'in', (ip) -> ip.type is 'data')
    data = input.getData 'in'

    # Clone the object so that the original isn't changed
    object = clone data

    for property in propData
      delete object[property.data]

    output.sendDone out: object
    input.buffer.set 'property', []
