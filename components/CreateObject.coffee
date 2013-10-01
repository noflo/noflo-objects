noflo = require 'noflo'

class CreateObject extends noflo.Component
  constructor: ->
    @inPorts =
      start: new noflo.Port 'bang'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.start.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.start.on "data", =>
      @outPorts.out.send {}
      @outPorts.out.disconnect()
    @inPorts.start.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.start.on 'disconnect', =>
      @outPorts.out.disconnect()

exports.getComponent = -> new CreateObject
