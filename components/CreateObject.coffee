noflo = require 'noflo'

class CreateObject extends noflo.Component
  constructor: ->
    @inPorts = new noflo.InPorts
      start:
        datatype: 'bang'
        description: 'Signal to create a new object'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'
        description: 'A new empty object'

    @inPorts.start.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.start.on "data", =>
      @outPorts.out.send {}
    @inPorts.start.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.start.on 'disconnect', =>
      @outPorts.out.disconnect()

exports.getComponent = -> new CreateObject
