# @TODO: remove need for underscorejs
_ = require 'underscore'
noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Extend an incoming object to some predefined
    objects, optionally by a certain property'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object to extend'
      required: true
    base:
      datatype: 'object'
      description: 'Objects to extend with (one object per IP)'
      required: true
    key:
      datatype: 'string'
      description: 'Property name to extend with'
      required: false
    reverse:
      datatype: 'boolean'
      description: 'A string equal "true" if you want to reverse the order of extension algorithm'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'The object received on port "in" extended'
      required: true

  c.process (input, output) ->
    bases = []
    key = null
    reverse = false
    mergedBase = {}

    key = (input.buffer.find('key', (ip) -> ip.type is 'data').map (ip) -> ip.data)[0]
    bases = input.buffer.find('base', (ip) -> ip.type is 'data').map (ip) -> ip.data
    data = input.getData 'in'

    if key is undefined
      key = null
    return unless bases? and data?

    if input.has 'reverse'
      reverse = input.buffer.find('reverse', (ip) -> ip.type is 'data').map (ip) -> ip.data
      reverse = reverse[0]

      # Normally, the passed IP object is extended into base objects (i.e.
      # attributes in IP object takes precendence). Pass `true` to reverse
      # would make the passed IP object the base (i.e. attributes in base
      # objects take precedence.
      reverse = String(reverse) is 'true'

    if data?
      out = {}
      for base in bases
        # Only extend when there's no key specified...
        if not key? or
           # or when the specified attribute matches
           data[key]? and
           data[key] is base[key]
          _.extend(out, base)
      # Put on data
      if reverse
        c.outPorts.out.send _.extend {}, data, out
        c.outPorts.out.disconnect()
      else
        sendee = _.extend out, data
        c.outPorts.out.send sendee
        c.outPorts.out.disconnect()

    input.buffer.set 'base', []
    input.buffer.set 'key', []
    input.buffer.set 'reverse', []
    input.buffer.set 'in', []
