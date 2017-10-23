noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Given a key, return only the value matching that key
    in the incoming object'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'An object to extract property from'
      required: true
    key:
      datatype: 'string'
      description: 'Property names to extract (one property per IP)'
      required: true
      control: true

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Values of the property extracted (each value sent as a separate IP)'

  c.process (input, output) ->
    return unless input.has 'in'
    return unless input.hasStream 'key'
    keys = input.getStream 'key'
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> ip.data
    data = input.getData 'in'
    value = data

    # Loop through the keys we have
    for key in keys
      value = value[key]
      # Send the extracted value
      output.send out: value
    output.done()
