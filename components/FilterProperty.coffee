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
      control: true
      default: false
    keep:
      datatype: 'boolean'
      description: '"true" if matching properties must be kept, otherwise removed'
      control: true
      default: false
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

  c.keys = {}
  c.process (input, output) ->
    if input.hasStream 'key'
      c.keys[input.scope] = input.getStream 'key'
        .filter (ip) -> ip.type is 'data' and ip.data?
        .map (ip) -> new RegExp ip.data, "g"
      return output.done()
    return unless input.hasData('in') and c.keys[input.scope]?.length > 0
    return unless input.hasData 'recurse' if input.attached('recurse').length > 0
    return unless input.hasData 'keep' if input.attached('keep').length > 0

    legacy = false
    if input.has('accept') or input.has('regexp')
      legacy = true
      accepts = input.get('accept').data
      regexp = input.get('regexp').data

    # because we can have multiple data packets,
    # we want to get them all, and use just the data
    keys = c.keys[input.scope]
    data = input.getData 'in'
    recurse = input.getData 'recurse'
    keep = input.getData 'keep'
    if keep? and typeof keep is 'object'
      keep = keep.pop()

    unless legacy
      if typeof data is 'object'
        data = deepCopy data
        c.filter data, keys, recurse, keep, input
        output.sendDone data
      else
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

      return output.done() unless match
      output.sendDone newData
