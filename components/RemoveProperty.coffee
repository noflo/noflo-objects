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
      required: true
    property:
      datatype: 'string'
      description: 'Properties to remove (one per IP)'
      required: true

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object forwarded from input'

  c.process (input, output) ->
    return unless input.hasData 'in'
    return unless input.hasStream 'property'
    ip = input.get 'in'
    data = ip.data
    propData = input.getStream 'property'
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> ip.data

    # Clone the object so that the original isn't changed
    if ip.clonable
      object = clone data
    else
      object = data

    for property in propData
      delete object[property]

    output.sendDone out: object
