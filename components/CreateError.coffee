noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'bug'
  c.description = 'Create an Error object'
  c.inPorts.add 'start',
    datatype: 'string'
  c.outPorts.add 'out',
    datatype: 'object'

  c.forwardBrackets =
    start: ['out']
  c.process (input, output) ->
    data = input.getData 'start'

    if typeof data is 'string'
      err = new Error data
    else
      err = new Error 'Error'
      err.context = data
    output.send out: err
