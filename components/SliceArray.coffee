noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'array'
      description: 'Array to slice'
    begin:
      datatype: 'number'
      description: 'Beginning of the slicing'
      control: true
    end:
      datatype: 'number'
      description: 'End of the slicing'
      control: true
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'array'
      description: 'Result of the slice operation'
    error:
      datatype: 'string'

  c.process (input, output) ->
    return unless input.has 'in', 'begin'
    data = input.getData 'in'
    begin = input.getData 'begin'
    end = input.getData 'end'
    unless data.slice
      return output.ports.error.send "Data #{typeof data} cannot be sliced"
    sliced = data.slice begin, end unless end is null
    sliced = data.slice begin if end is null
    output.ports.out.send sliced
