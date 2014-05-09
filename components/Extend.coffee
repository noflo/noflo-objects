_ = require("underscore")
noflo = require("noflo")

class Extend extends noflo.Component

  description: "Extend an incoming object to some predefined
  objects, optionally by a certain property"

  constructor: ->
    @bases = []
    @mergedBase = {}
    @key = null
    @reverse = false

    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Object to extend'
      base:
        datatype: 'object'
        description: 'Objects to extend with (one object per IP)'
      key:
        datatype: 'string'
        description: 'Property name to extend with'
      reverse:
        datatype: 'string'
        description: 'A string equal "true" if you want to reverse the order of extension algorithm'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'
        description: 'The object received on port "in" extended'

    @inPorts.base.on "connect", =>
      @bases = []

    @inPorts.base.on "data", (base) =>
      @bases.push base if base?

    @inPorts.key.on "data", (@key) =>

    @inPorts.reverse.on "data", (reverse) =>
      # Normally, the passed IP object is extended into base objects (i.e.
      # attributes in IP object takes precendence). Pass `true` to reverse
      # would make the passed IP object the base (i.e. attributes in base
      # objects take precedence.
      @reverse = reverse is 'true'

    @inPorts.in.on "connect", (group) =>

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
      if @reverse
        @outPorts.out.send _.extend {}, incoming, out
      else
        @outPorts.out.send _.extend out, incoming

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new Extend
