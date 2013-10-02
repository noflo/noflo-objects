noflo = require("noflo")
_ = require("underscore")

class ExtractProperty extends noflo.Component

  description: "Given a key, return only the value matching that key
  in the incoming object"

  constructor: ->
    @inPorts =
      in: new noflo.Port
      key: new noflo.Port
    @outPorts =
      out: new noflo.Port

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
