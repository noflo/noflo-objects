_ = require("underscore")
noflo = require("noflo")

class Extend extends noflo.Component

  description: "Extend an incoming object to some predefined
  objects, optionally by a certain property"

  constructor: ->
    @bases = []
    @key = null

    @inPorts =
      in: new noflo.Port
      base: new noflo.Port
      key: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.base.on "data", (base) =>
      if base?
        @bases.push(base)
      else
        @bases = []

    @inPorts.key.on "data", (@key) =>

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (incoming) =>
      out = {}

      for base in @bases
        # Only extend when there's no key specified...
        if not @key? or
           # or when the specified attribute matches
           incoming[@key]? and
           incoming[@key] is base[@key]
          _.extend(out, base)

      # Put on incoming
      _.extend(out, incoming)

      @outPorts.out.send(out)

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new Extend
