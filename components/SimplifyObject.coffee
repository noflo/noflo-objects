noflo = require 'noflo'
_ = require 'underscore'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts = new noflo.InPorts
    in:
      datatype: 'all'
      description: 'Object to simplify'
  c.outPorts = new noflo.OutPorts
    out:
      datatype: 'all'
      description: 'Simplified object'

  c.simplify = (data) ->
    if _.isArray data
      if data.length is 1
        return data[0]
      return data
    unless _.isObject data
      return data

    c.simplifyObject data

  c.simplifyObject = (data) ->
    keys = _.keys data
    if keys.length is 1 and keys[0] is '$data'
      return c.simplify data['$data']
    simplified = {}
    _.each data, (value, key) =>
      simplified[key] = c.simplify value
    simplified

  c.process (input, output) ->
    return unless input.has 'in'
    data = input.getData 'in'
    output.ports.out.send c.simplify data
