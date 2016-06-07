noflo = require 'noflo'
{ deepCopy } = require 'owl-deepcopy'
_ = require 'underscore'

buffer =
  get: (input, name = null) ->
    if input.scope isnt null
      if name?
        return input.ports[name].scopedBuffer[input.scope]
      return input.port.scopedBuffer[input.scope]

    if name?
      return input.ports[name].buffer
    return input.port.buffer

  where: (input, name = null, args = {}) ->
    b = buffer.get(input, name)

    if args? and Object.keys(args).length > 0
      b = b.filter (ip) ->
        if args.hasData
          return false unless ip.data?
        if args.type
          if typeof args.type is 'array'
            return false unless ip.type in args.type
          return false unless ip.type is args.type
        true

    if args.getData
      b = b.map (ip) -> ip.data

    if b.length is 1
      return b[0]
    if b.length is 0
      return null

    b

  filter: (input, cb) ->
    if input.scope isnt null
      input.port.scopedBuffer[input.scope] = input.port.scopedBuffer[input.scope].filter cb
    else
      input.port.buffer = input.port.buffer.filter cb

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

  c.keys = {}

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
    return buffer.get(input).pop() if input.ip.type isnt 'data'
    return unless input.has 'in', 'key'

    legacy = false
    if input.has('accept') or input.has('regexp')
      legacy = true
      accepts = input.get('accept').data
      regexp = input.get('regexp').data

    # because we can have multiple data packets,
    # we want to get them all, and use just the data
    keys = buffer.where input, 'key', hasData: true, type: 'data'
      .map (ip) -> new RegExp ip.data, "g"

    c.keys[input.scope] = keys
    data = input.getData 'in'
    recurse = false
    recurse = buffer.where input, 'recurse', hasData: true, type: 'data', getData: true
    keep = false
    keep = buffer.where input, 'keep', hasData: true, type: 'data', getData: true
    if keep? and typeof keep is 'object'
      keep = keep.pop()
      input.ports.keep.buffer = input.ports.keep.buffer.filter (ip) -> false

    unless legacy
      if typeof data is 'object'
        data = deepCopy data
        c.filter data, c.keys[input.scope], recurse, keep, input
        c.outPorts.out.send data
        output.done()
    # Legacy mode
    else
      console.log 'is legacy'
      newData = {}
      match = false
      for property, value of data
        console.log 'looping'
        console.log accepts
        console.log property
        console.log value
        if accepts.indexOf(property) isnt -1
          console.log 'is in accepts'
          console.log property, value
          newData[property] = value
          match = true
          continue

        for expression in regexp
          regex = new RegExp expression
          console.log regex
          if regex.exec property
            console.log 'matches regex'
            newData[property] = value
            match = true

      return unless match
      output.out.send newData
      # output.out.disconnect()
      # output.done()

      console.log 'clearing buffer'
      # clearing the buffer
      #buffer.filter input, (ip) -> ip.type is 'data' and ip.data?
