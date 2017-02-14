noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.description = 'call a method on an object'
  c.icon = 'gear'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object on which a method will be called'
      required: true
    method:
      datatype: 'string'
      description: 'Name of the method to call'
      required: true
      control: true
    arguments:
      datatype: 'all'
      description: 'Arguments given to the method (one argument per IP)'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Value returned by the method call'
      required: true
    error:
      datatype: 'object'

  c.process (input, output) ->
    return unless input.hasData 'method', 'in'
    if input.attached('arguments').length > 0
      return unless input.hasData 'arguments'
    args = []

    # because we can have multiple data packets,
    # we want to get them all, and use just the data
    argsIn = input.getStream 'arguments'
      .filter (ip) -> ip.type is 'data' and ip.data?
      .map (ip) -> ip.data

    args = args.concat argsIn
    data = input.getData 'in'
    method = input.getData 'method'

    unless data[method]
      output.sendDone new Error  "Method '#{method}' not available"
      return

    output.sendDone out: data[method].apply(data, args)
