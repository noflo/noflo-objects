noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'array'
      description: 'Array to slice'
      required: true
    begin:
      datatype: 'number'
      description: 'Beginning of the slicing'
      required: true
    end:
      datatype: 'number'
      description: 'End of the slicing'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'array'
      description: 'Result of the slice operation'
      required: true
    error:
      datatype: 'object'

  c.process (input, output) ->
    return unless input.hasData 'in', 'begin'
    return unless input.hasData 'end' if input.attached('end').length > 0

    data = input.getData 'in'
    begin = input.getData 'begin'
    unless data?.slice
      return output.done new Error "Data #{typeof data} cannot be sliced"

    if input.hasData 'end'
      end = input.getData 'end'
      sliced = data.slice begin, end
    else
      sliced = data.slice begin

    output.sendDone out: sliced
