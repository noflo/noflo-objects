noflo = require("noflo")
_ = require("underscore")

class Keys extends noflo.Component

  description: "gets only the keys of an object and forward them as an array"

  constructor: ->
    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Object to get keys from'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'string'
        description: 'Keys from the incoming object (one per IP)'

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      @outPorts.out.send key for key in _.keys data

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new Keys
