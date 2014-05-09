noflo = require 'noflo'

class UniqueArray extends noflo.Component
  constructor: ->
    @inPorts = new noflo.InPorts
      in:
        datatype: 'array'
        description: 'Array to get unique values from'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'array'
        description: 'Array containing only unique values from the input array'

    @inPorts.in.on 'data', (data) =>
      @outPorts.out.send @unique data
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

  unique: (array) ->
    seen = {}
    newArray = []
    for member in array
      seen[member] = member
    for member of seen
      newArray.push member
    return newArray

exports.getComponent = -> new UniqueArray
