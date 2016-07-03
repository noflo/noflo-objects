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
      datatype: 'string'

  c.process (input, output) ->
    # because we only want to use non-brackets
    return input.buffer.get().pop() if input.ip.type isnt 'data'
    return unless input.has 'in', 'begin'
    data = input.getData 'in'
    begin = input.getData 'begin'
    end = input.getData 'end'

    unless data?.slice
      return output.sendDone error: "Data #{typeof data} cannot be sliced"
    sliced = data.slice begin, end if end?
    sliced = data.slice begin if end is null or end is undefined
    output.sendDone out: sliced
