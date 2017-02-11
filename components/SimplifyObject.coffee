noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Simplify an objectgi'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'all'
      description: 'Object to simplify'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Simplified object'

  simplify = (data) ->
    if Array.isArray data
      if data.length is 1
        return data[0]
      return data
    unless typeof data is 'object'
      return data

    simplifyObject data

  simplifyObject = (data) ->
    keys = Object.keys data
    if keys.length is 1 and keys[0] is '$data'
      return simplify data['$data']

    simplified = {}
    for key, value of data
      simplified[key] = simplify value
    simplified

  c.process (input, output) ->
    data = input.getData 'in'
    output.sendDone out: simplify data
