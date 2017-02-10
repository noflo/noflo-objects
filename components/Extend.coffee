noflo = require 'noflo'

extend = (object, properties, other) ->
  for key, val of properties
    object[key] = val
  if other?
    for key, val of other
      object[key] = val
  object

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
      default: false
      control: true
    reverse:
      datatype: 'boolean'
      description: 'A string equal "true" if you want to reverse the order of extension algorithm'
      default: false
      control: true

  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'The object received on port "in" extended'
      required: true

  c.process (input, output) ->
    return unless input.hasData 'in'
    return unless input.has 'base'
    return unless input.hasData 'key' if input.attached('key').length > 0
    return unless input.hasData 'reverse' if input.attached('reverse').length > 0

    reverse = false
    key = input.getData 'key'

    bases = input.getStream('base')
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> ip.data
    data = input.getData 'in'

    if key is undefined
      key = null

    # Normally, the passed IP object is extended into base objects (i.e.
    # attributes in IP object takes precendence). Pass `true` to reverse
    # would make the passed IP object the base (i.e. attributes in base
    # objects take precedence.
    reverse = String(input.getData('reverse')) is 'true'

    out = {}
    for base in bases
      # Only extend when there's no key specified...
      # or when the specified attribute matches
      if not key? or data[key]? and data[key] is base[key]
        out = extend out, base

    # Put on data
    if reverse
      output.sendDone extend {}, data, out
    else
      output.sendDone extend out, data
