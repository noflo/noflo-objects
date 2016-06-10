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

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Values of the property extracted (each value sent as a separate IP)'

  c.process (input, output) ->
    # because we only want to use non-brackets
    return input.buffer.get().pop() if input.ip.type isnt 'data'
    return unless input.has 'key', 'in'
    keys = input.getData 'key'
    data = input.getData 'in'
    value = data

    # Loop through the keys we have
    for key in keys
      value = value[key]

    # Send the extracted value
    output.sendDone out: value
