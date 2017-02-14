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

  merge = (origin, object) ->
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
            origin[key] = merge(oValue, value)
          # Replace if simple value
          else
            origin[key] = value

      # Use object if not
      else
        origin[key] = value

    origin

  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    inData = input.getStream 'in'
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> ip.data
    output.sendDone inData.reduce merge, {}
