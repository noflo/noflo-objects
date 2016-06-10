noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.description = 'merges all incoming objects into one'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Objects to merge (one per IP)'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'
      description: 'A new object containing the merge of input objects'

  c.merge = (origin, object) ->
    # Go through the incoming object
    for key, value of object
      oValue = origin[key]

      # If property already exists, merge
      if oValue?
        # ... depending on type of the pre-existing property
        switch toString.call(oValue)
          # Concatenate if an array
          when "[object Array]"
            origin[key].push.apply(origin[key], value)
          # Merge down if an object
          when "[object Object]"
            origin[key] = c.merge(oValue, value)
          # Replace if simple value
          else
            origin[key] = value

      # Use object if not
      else
        origin[key] = value

    origin

  c.process (input, output) ->
    inData = input.buffer.find 'in', (ip) -> ip.type is 'data' and ip.data?
    return unless inData.length is 2
    output.ports.out.send inData.reduce c.merge, {}
