noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    property:
      datatype: 'all'
      required: true
      control: true
      description: 'property to duplicate'
    separator:
      datatype: 'string'
      default: '/'
      control: true
      description: 'separator to use to join property'
    in:
      datatype: 'object'
      description: 'object to duplicate property on'
      required: true
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'

  c.process (input, output) ->
    return unless input.hasData 'property', 'separator', 'in'
    [prop, sep, data] = input.getData 'property', 'separator', 'in'

    properties = {}
    separator = if sep? then sep else '/'

    if prop
      if typeof prop is 'object'
        output.done new Error 'Property name cannot be an object'
        return

      propParts = prop.split '='
      if propParts.length > 2
        properties[propParts.pop()] = propParts
      else
        properties[propParts[1]] = propParts[0]

    if data
      for newprop, original of properties
        if typeof original is 'string'
          data[newprop] = data[original]
          continue

        newValues = []
        for originalProp in original
          newValues.push data[originalProp]
        data[newprop] = newValues.join separator

      output.sendDone data
