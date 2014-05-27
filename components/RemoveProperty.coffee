noflo = require 'noflo'
_ = require 'underscore'

class RemoveProperty extends noflo.Component
  icon: 'ban'
  constructor: ->
    @properties = []
    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Object to remove properties from'
      property:
        datatype: 'string'
        description: 'Properties to remove (one per IP)'
      reset:
        datatype: 'bang'
        description: 'Clear the list of properties to remove'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'
        description: 'Object forwarded from input'

    @inPorts.property.on 'data', (data) =>
      @properties.push data
    @inPorts.reset.on 'data', =>
      @properties = []

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (data) =>
      return unless @properties.length
      @outPorts.out.send @removeProperties data
    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

  removeProperties: (object) ->
    # Clone the object so that the original isn't changed
    object = _.clone(object)

    for property in @properties
      delete object[property]
    return object

exports.getComponent = -> new RemoveProperty
