noflo = require 'noflo'

class SetProperty extends noflo.Component
  constructor: ->
    @properties = {}

    @inPorts = new noflo.InPorts
      property:
        datatype: 'all'
      in:
        datatype: 'object'
        description: 'Object to set property on'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'
        description: 'Object forwared from input'

    @inPorts.property.on 'data', (data) =>
      @setProperty data

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (data) =>
      @addProperties data
    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

  setProperty: (prop) ->
    if typeof prop is 'object'
      @prop = prop
      return

    propParts = prop.split '='
    @properties[propParts[0]] = propParts[1]

  addProperties: (object) ->
    for property, value of @properties
      object[property] = value

    @outPorts.out.send object

exports.getComponent = -> new SetProperty
