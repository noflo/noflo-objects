noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'given a regexp matching any key of an incoming
  object as a data IP, replace the key with the provided string'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object to replace a key from'
    pattern:
      datatype: 'all'
      control: true
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'Object forwared from input'

  c.process (input, output) ->
    return unless input.has 'in', 'pattern'
    data = input.getData 'in'
    patterns = input.getData 'pattern'
    newKey = null

    for key, value of data
      for pattern, replace of patterns
        pattern = new RegExp(pattern)

        if key.match(pattern)?
          newKey = key.replace(pattern, replace)
          data[newKey] = value
          delete data[key]

    output.ports.out.data data
