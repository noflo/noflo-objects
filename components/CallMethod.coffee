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
    # because we only want to use non-brackets
    input.buffer.get().pop() if input.ip.type isnt 'data'
    return unless input.has 'method', 'in'
    args = []

    # because we can have multiple data packets, we want to get them all, and use just the data
    argsIn = (input.ports.arguments.buffer.filter (ip) -> ip.type is 'data' and ip.data?).map (ip) -> ip.data
    data = input.getData 'in'
    method = input.getData 'method'
    args = args.concat argsIn

    unless data[method]
      output.sendDone ṇew Error  "Method '#{method}' not available"
      return

    output.sendDone out: data[method].apply(data, args)
    input.buffer.set 'arguments', []