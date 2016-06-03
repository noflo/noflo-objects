noflo = require 'noflo'
_ = require 'underscore'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Given a key, return only the value matching that key
    in the incoming object'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'An object to extract property from'
    key:
      datatype: 'string'
      description: 'Property names to extract (one property per IP)'

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Values of the property extracted (each value sent as a separate IP)'

  c.keys = []

  c.process (input, output) ->
    if input.has 'key'
      keys = input.getData 'key'
      if keys?
        c.keys.push keys

    if input.has 'in'
      data = input.getData 'in'
      if c.keys? and _.isObject(data)
        value = data

        # Loop through the keys we have
        for key in c.keys
          value = value[key]

        c.keys = []
        # Send the extracted value
        c.outPorts.out.send value
