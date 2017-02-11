noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Join all values of a passed packet together as a
  string with a predefined delimiter'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object to join values from'
      required: true
    delimiter:
      datatype: 'string'
      description: 'Delimiter to join values'
      control: true
      default: ','

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'string'
      description: 'String conversion of all values joined with delimiter into one string'
      required: true
    error:
      datatype: 'object'

  c.process (input, output) ->
    return unless input.hasData 'in'
    return unless input.hasData 'delimiter' if input.attached('delimiter').length > 0

    delimiter = input.getData 'delimiter' or ','
    data = input.getData 'in'

    if data? and typeof data is 'object'
      keys = Object.keys data
      length = keys.length
      values = Array(length)
      for i in [0..length-1]
        values[i] = data[keys[i]]
      output.sendDone out: values.join(delimiter)
    else
      output.sendDone error: new Error(typeof(data) + ' is not a valid object to join')
