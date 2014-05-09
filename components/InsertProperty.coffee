noflo = require("noflo")
_ = require("underscore")

class InsertProperty extends noflo.Component

  description: "Insert a property into incoming objects."

  constructor: ->
    @properties = {}

    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Object to insert property into'
      property:
        datatype: 'all'
        description: 'Property to insert (property sent as group, value sent as IP)'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'
        description: 'Object received as input with added properties'

    @inPorts.property.on "connect", =>
      @properties = {}
    @inPorts.property.on "begingroup", (@key) =>
    @inPorts.property.on "data", (value) =>
      @properties[@key] = value if @key?
    @inPorts.property.on "endgroup", =>
      @key = null

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      data = {} unless _.isObject data
      data[key] = value for key, value of @properties
      @outPorts.out.send data

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new InsertProperty
