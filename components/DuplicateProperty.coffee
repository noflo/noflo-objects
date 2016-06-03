noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.properties = {}
  c.separator = '/'

  c.inPorts = new noflo.InPorts
    property:
      datatype: 'all'
    separator:
      datatype: 'string'
    in:
      datatype: 'object'

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'

  c.process (input, output) ->
    return unless input.has 'property', 'separator', 'in'
    [prop, separator, data] = input.getData 'property', 'separator', 'in'
    return unless input.ip.type is 'data'

    if prop
      if typeof prop is 'object'
        c.prop = prop
        return

      propParts = prop.split '='
      if propParts.length > 2
        c.properties[propParts.pop()] = propParts
        return

      c.properties[propParts[1]] = propParts[0]

    if data
      for newprop, original of c.properties
        if typeof original is 'string'
          object[newprop] = object[original]
          continue

        newValues = []
        for originalProp in original
          newValues.push object[originalProp]
        object[newprop] = newValues.join c.separator

      c.outPorts.out.send object
