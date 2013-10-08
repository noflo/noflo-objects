noflo = require("noflo")

class CallMethod extends noflo.Component

  description: "call a method on an object"
  icon: 'gear'

  constructor: ->
    @method = null
    @args   = []

    @inPorts =
      in: new noflo.Port 'object'
      method: new noflo.Port 'string'
      arguments: new noflo.Port 'all'
    @outPorts =
      out: new noflo.Port 'all'
      error: new noflo.Port 'string'

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
