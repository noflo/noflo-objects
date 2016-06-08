_ = require 'underscore'

exports.getComponent = ->
  c = new noflo.Component

  c.description = 'Join all values of a passed packet together as a
  string with a predefined delimiter'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object to join values from'
    delimiter:
      datatype: 'string'
      description: 'Delimiter to join values'

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'string'
      description: 'String conversion of all values joined with delimiter into one string'

  c.process (input, output) ->
    return unless input.ip.type is 'data'

    delimiter = ','
    if input.has 'delimiter'
      delimiter = input.getData 'delimiter'

    if input.has 'in'
      data = input.getData 'in'
      if typeof data is 'object'
        keys = Object.keys data
        length = keys.length
        values = Array(length)
        for i in length
          values[i] = data[keys[i]]

        c.outPorts.out.send values.join(delimiter)
