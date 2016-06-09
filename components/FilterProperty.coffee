noflo = require 'noflo'
{ deepCopy } = require 'owl-deepcopy'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'filter'
  c.description = 'Filter out some properties by matching RegExps
  against the keys of incoming objects'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object to filter properties from'
      required: true
    key:
      datatype: 'string'
      description: 'Keys to filter (one key per IP)'
      required: true
    recurse:
      datatype: 'boolean'
      description: '"true" to recurse on the object\'s values'
    keep:
      datatype: 'boolean'
      description: '"true" if matching properties must be kept, otherwise removed'
    # Legacy mode
    accept:
      datatype: 'all'
    regexp:
      datatype: 'all'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'object'

  c.filter = (object, keys, recurse, keep, input) ->
    for key, value of object
      isMatched = false

      # the keys are filters we want to match in the object
      for filter in keys
        match = key.match filter

        # if they match, we delete them
        matchButDontKeep = not keep and match
        keepButDontMatch = keep and not match
        if matchButDontKeep or keepButDontMatch
          delete object[key]
          isMatched = true
          break

      if not isMatched and recurse and typeof value is 'object'
        c.filter value, keys, recurse, keep, input

  c.process (input, output) ->
    # because we only want to use non-brackets
    return input.buffer.get().pop() if input.ip.type isnt 'data'
    return unless input.has 'in', 'key'

    legacy = false
    if input.has('accept') or input.has('regexp')
      legacy = true
      accepts = input.get('accept').data
      regexp = input.get('regexp').data

    # because we can have multiple data packets,
    # we want to get them all, and use just the data
    keys = input.buffer
      .find 'key', (ip) -> ip.type is 'data' and ip.data?
      .map (ip) -> new RegExp ip.data, "g"

    data = input.getData 'in'
    recurse = false
    recurse = (input.buffer
      .find 'recurse', (ip) -> ip.type is 'data' and ip.data?
      .map (ip) -> ip.data)[0]

    keep = (input.buffer
      .find 'keep', (ip) -> ip.type is 'data' and ip.data?
      .map (ip) -> ip.data)

    if keep? and typeof keep is 'object'
      keep = keep.pop()

    unless legacy
      if typeof data is 'object'
        data = deepCopy data
        c.filter data, keys, recurse, keep, input
        c.outPorts.out.send data
        output.done()
    # Legacy mode
    else
      newData = {}
      match = false
      for property, value of data
        if accepts.indexOf(property) isnt -1
          newData[property] = value
          match = true
          continue

        for expression in regexp
          regex = new RegExp expression
          if regex.exec property
            newData[property] = value
            match = true

      return unless match
      output.out.send newData

      # clearing the buffer
      input.buffer.set 'keep', []
      input.buffer.set 'keys', []
