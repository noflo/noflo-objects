noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Simplify an object'

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'all'
      description: 'Object to simplify'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Simplified object'

  c.simplify = (data) ->
    if Array.isArray data
      if data.length is 1
        return data[0]
      return data
    unless typeof data is 'object'
      return data

    c.simplifyObject data

  c.simplifyObject = (data) ->
    keys = Object.keys data
    if keys.length is 1 and keys[0] is '$data'
      return c.simplify data['$data']

    simplified = {}
    for key, value of data
      simplified[key] = c.simplify value
    simplified

  c.process (input, output) ->
    data = input.getData 'in'
    output.sendDone out: c.simplify data
