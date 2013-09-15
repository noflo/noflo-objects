noflo = require("noflo")

class CallMethod extends noflo.Component

  description: "call a method on an object"

  constructor: ->
    @method = null
    @args   = null

    @inPorts =
      in: new noflo.Port 'object'
      method: new noflo.Port 'string'
      arguments: new noflo.Port 'array'
    @outPorts =
      out: new noflo.Port 'all'
      error: new noflo.Port 'string'

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
      @args = null

    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

    @inPorts.method.on "data", (data) =>
      @method = data

    @inPorts.arguments.on 'data', (data) =>
      @args = data

exports.getComponent = -> new CallMethod
