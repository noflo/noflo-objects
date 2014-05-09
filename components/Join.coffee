_ = require("underscore")
noflo = require("noflo")

class Join extends noflo.Component

  description: "Join all values of a passed packet together as a
  string with a predefined delimiter"

  constructor: ->
    @delimiter = ","

    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Object to join values from'
      delimiter:
        datatype: 'string'
        description: 'Delimiter to join values'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'string'
        description: 'String conversion of all values joined with delimiter into one string'

    @inPorts.delimiter.on "data", (@delimiter) =>

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (object) =>
      if _.isObject object
        @outPorts.out.send _.values(object).join(@delimiter)

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new Join
