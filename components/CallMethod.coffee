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
    if input.ip.type isnt 'data'
      buf = if input.scope isnt null then input.port.scopedBuffer[input.scope] else input.port.buffer
      return buf.pop()

    return unless input.has 'method', 'in'

    args = []

    # because we can have multiple data packets, we want to get them all, and use just the data
    argsIn = (input.ports.arguments.buffer.filter (ip) -> ip.type is 'data' and ip.data?).map (ip) -> ip.data
    data = input.getData 'in'
    method = input.getData 'method'

    args = args.concat argsIn

    unless data[method]
      msg = "Method '#{method}' not available"
      if output.ports.error.isAttached()
        output.ports.error.send msg
        output.ports.error.disconnect()
        return
      throw new Error msg

    c.outPorts.out.send data[method].apply(data, args)
    output.done()
