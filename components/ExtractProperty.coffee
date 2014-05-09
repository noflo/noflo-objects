noflo = require("noflo")
_ = require("underscore")

class ExtractProperty extends noflo.Component

  description: "Given a key, return only the value matching that key
  in the incoming object"

  constructor: ->
    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'An object to extract property from'
      key:
        datatype: 'string'
        description: 'Property names to extract (one property per IP)'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'all'
        description: 'Values of the property extracted (each value sent as a separate IP)'

    @inPorts.key.on "connect", =>
      @keys = []
    @inPorts.key.on "data", (key) =>
      @keys.push key

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      if @keys? and _.isObject(data)
        value = data

        # Loop through the keys we have
        for key in @keys
          value = value[key]

        # Send the extracted value
        @outPorts.out.send value

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new ExtractProperty
