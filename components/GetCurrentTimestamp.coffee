noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'clock-o'
  c.description = 'Send out the current timestamp'

  c.inPorts.add 'in',
    datatype: 'bang'
    description: 'Causes the current timestamp to be sent out'
    process: (event) ->
      switch event
        when 'data'
          c.outPorts.out.send Date.now()
        when 'disconnect'
          c.outPorts.out.disconnect()
  c.outPorts.add 'out',
    datatype: 'int'

  c
