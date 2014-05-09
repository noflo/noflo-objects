noflo = require "noflo"

class CreateDate extends noflo.Component
  description: 'Create a new Date object from string'
  icon: 'clock-o'
  constructor: ->
    @inPorts = new noflo.InPorts
      in:
        datatype: 'string'
        description: 'A string representation of a date in RFC2822/IETF/ISO8601 format'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'
        description: 'A new Date object'

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on "data", (data) =>
      if data is "now" or data is null or data is true
        date = new Date
      else
        date = new Date data
      @outPorts.out.send date
    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

exports.getComponent = -> new CreateDate
