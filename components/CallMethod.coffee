noflo = require("noflo")

class CallMethod extends noflo.Component

  description: "call a method on an object"
  icon: 'gear'

  constructor: ->
    @method = null
    @args   = []

    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Object on which a method will be called'
      method:
        datatype: 'string'
        description: 'Name of the method to call'
      arguments:
        datatype: 'all'
        description: 'Arguments given to the method (one argument per IP)'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'all'
        description: 'Value returned by the method call'
      error:
        datatype: 'object'

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on "data", (data) =>
      return unless @method
      unless data[@method]
        msg = "Method '#{@method}' not available"
        if @outPorts.error.isAttached()
          @outPorts.error.send msg
          @outPorts.error.disconnect()
          return
        throw new Error msg

      @outPorts.out.send data[@method].apply(data, @args)
      @args = []

    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

    @inPorts.method.on "data", (data) =>
      @method = data

    @inPorts.arguments.on 'connect', =>
      @args = []

    @inPorts.arguments.on 'data', (data) =>
      @args.push data

exports.getComponent = -> new CallMethod
