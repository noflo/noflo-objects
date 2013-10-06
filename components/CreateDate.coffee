noflo = require "noflo"

class CreateDate extends noflo.Component
  description: 'Create a new Date object from string'
  icon: 'time'
  constructor: ->
    @inPorts =
      in: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.in.on "data", (data) =>
      if data is "now" or data is null or data is true
        date = new Date
      else
        date = new Date data
      @outPorts.out.send date
      @outPorts.out.disconnect()

exports.getComponent = -> new CreateDate
