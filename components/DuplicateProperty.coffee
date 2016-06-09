noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    property:
      datatype: 'all'
      required: true
      description: 'property to duplicate'
    separator:
      datatype: 'string'
      description: 'default is `/`'
      required: true
    in:
      datatype: 'object'
      description: 'object to duplicate property on'
      required: true
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'

  c.process (input, output) ->
    return unless input.has 'property', 'separator', 'in'
    [prop, sep, data] = input.getData 'property', 'separator', 'in'
    return unless input.ip.type is 'data'

    properties = {}
    separator = if sep? then sep else '/'

    if prop
      if typeof prop is 'object'
        return

      propParts = prop.split '='
      if propParts.length > 2
        properties[propParts.pop()] = propParts
        return

      properties[propParts[1]] = propParts[0]

    if data
      for newprop, original of properties
        if typeof original is 'string'
          object[newprop] = object[original]
          continue

        newValues = []
        for originalProp in original
          newValues.push object[originalProp]
        object[newprop] = newValues.join separator

      output.port.out.data object
