noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'indent'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'object'
      description: 'Object to get keys from'
      required: true
    key:
      datatype: 'string'
      description: 'Keys to extract from the object (one key per IP)'
      required: true
    sendgroup:
      datatype: 'boolean'
      description: 'true to send keys as groups around value IPs, false otherwise'
      control: true
      default: false
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Values extracts from the input object given the input keys (one value per IP, potentially grouped using the key names)'
    object:
      datatype: 'object'
      description: 'Object forwarded from input if at least one property matches the input keys'
    missed:
      datatype: 'object'
      description: 'Object forwarded from input if no property matches the input keys'

  c.process (input, output) ->
    return unless input.hasData 'in'
    return unless input.hasStream 'key'
    return unless input.hasData 'sendgroup' if input.attached('sendgroup').length > 0

    keys = input.getStream 'key'
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> ip.data
    data = input.getData 'in'

    sendGroup = input.getData('sendgroup')
    sendGroup = sendGroup is 'true' or sendGroup is true

    unless typeof data is 'object'
      output.sendDone new Error 'Data is not an object'
      return
    if data is null
      output.sendDone new Error 'Data is NULL'
      return
    for key in keys
      if data[key] is undefined
        output.send missed: new noflo.IP 'openBracket', key if sendGroup
        output.send missed: new noflo.IP 'data', data
        output.send missed: new noflo.IP 'closeBracket', key if sendGroup

      output.send out: new noflo.IP 'openBracket', key if sendGroup
      output.send out: new noflo.IP 'data', data[key]
      output.send out: new noflo.IP 'closeBracket', key if sendGroup

    output.send object: new noflo.IP 'data', data
    output.done()
