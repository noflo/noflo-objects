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
    return unless input.has 'key', 'in', (ip) -> ip.type is 'data'

    keys = (input.buffer.find 'key', (ip) -> ip.type is 'data').map (ip) -> ip.data
    openBrackets = input.buffer.find 'in', (ip) -> ip.type is 'openbracket'
    dataBuf = (input.buffer.find 'in', (ip) -> ip.type is 'data')
    data = dataBuf[0].data

    sendGroup = false
    if input.has 'sendgroup'
      sendgroupData = input.buffer.find 'sendgroup', (ip) -> ip.type is 'data'
      sendGroup = String(sendgroupData[0].data) is 'true'

    return unless keys? and data?

    unless typeof data is 'object'
      c.error data, new Error 'Data is not an object'
      return
    if data is null
      c.error data, new Error 'Data is NULL'
      return
    for key in keys
      if data[key] is undefined
        # we have to manually connect because mixing the old protocol
        # and the new one. In the translation, it should consider the
        # the openBracket a connect if it does not have data, but it
        # actually counts the first openBracket as connect
        output.ports.missed.connect()
        output.ports.missed.openBracket key if sendGroup
        output.ports.missed.data data
        output.ports.missed.closeBracket() if sendGroup
        output.ports.missed.disconnect()
        errored = true

      output.ports.out.connect()
      output.ports.out.openBracket group for group in openBrackets
      output.ports.out.openBracket key if sendGroup
      output.ports.out.data data[key]
      output.ports.out.closeBracket() if sendGroup
      output.ports.out.closeBracket() for group in openBrackets
      output.ports.out.disconnect()

    # if it errored, don't send stuff out object just clear the buffer
    if errored
      input.buffer.set 'in', []
      input.buffer.set 'key', []
      input.buffer.set 'sendgroup', []
      return

    output.ports.object.connect()
    output.ports.object.openBracket group for group in openBrackets
    output.ports.object.data data
    output.ports.object.closeBracket() for group in openBrackets
    output.ports.object.disconnect()

    input.buffer.set 'in', []
    input.buffer.set 'key', []
    input.buffer.set 'sendgroup', []
