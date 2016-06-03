# @TODO: remove need for underscorejs
_ = require 'underscore'
noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Extend an incoming object to some predefined
    objects, optionally by a certain property'

  c.bases = []
  c.mergedBase = {}
  c.key = null
  c.reverse = false

  c.inPorts = new noflo.InPorts
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
      datatype: 'boolean'
      description: 'A string equal "true" if you want to reverse the order of extension algorithm'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'The object received on port "in" extended'

  c.process (input, output) ->
    if input.has 'base'
      base = input.getData 'base'
      c.bases.push base if base?

    if input.has 'key'
      c.key = input.getData 'key'

    if input.has 'reverse'
      reverse = input.getData 'reverse'
      # Normally, the passed IP object is extended into base objects (i.e.
      # attributes in IP object takes precendence). Pass `true` to reverse
      # would make the passed IP object the base (i.e. attributes in base
      # objects take precedence.
      c.reverse = String(reverse) is 'true'

    if input.has 'in'
      data = input.getData 'in'
      if data?
        out = {}
        for base in c.bases
          # Only extend when there's no key specified...
          if not c.key? or
             # or when the specified attribute matches
             data[c.key]? and
             data[c.key] is base[c.key]
            _.extend(out, base)
        # Put on data
        if c.reverse
          c.outPorts.out.send _.extend {}, data, out
        else
          c.outPorts.out.send _.extend out, data

      c.bases = []
      c.key = null
      c.reverse = false
