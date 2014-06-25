noflo = require 'noflo'

class SetPropertyValue extends noflo.Component
  constructor: ->
    @property = null
    @data = []
    @groups = []
    @keep = false

    @inPorts = new noflo.InPorts
      property:
        datatype: 'string'
        description: 'Property name to set value on'
      value:
        datatype: 'all'
        description: 'Property value to set'
      in:
        datatype: 'object'
        description: 'Object to set property value on'
      # Persist value
      keep:
        datatype: 'boolean'
        description: 'true if input value must be kept around, false to drop it after the value is set'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'
        description: 'Object forwarded from the input'

    @inPorts.keep.on 'data', (keep) =>
      @keep = String(keep) is 'true'

    @inPorts.property.on 'data', (data) =>
      @property = data
      @addProperties() if @value != undefined and @data.length
    @inPorts.value.on 'data', (data) =>
      @value = data
      @addProperties() if @property and @data.length

    @inPorts.in.on 'begingroup', (group) =>
      @groups.push group
    @inPorts.in.on 'data', (data) =>
      if @property and @value != undefined
        @addProperty
          data: data
          group: @groups.slice 0
        return
      @data.push
        data: data
        group: @groups.slice 0
    @inPorts.in.on 'endgroup', =>
      @groups.pop()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect() if @property and @value != undefined
      delete @value unless @keep

  addProperty: (object) ->
    object.data[@property] = @value
    for group in object.group
      @outPorts.out.beginGroup group
    @outPorts.out.send object.data
    for group in object.group
      @outPorts.out.endGroup()

  addProperties: ->
    @addProperty object for object in @data
    @data = []
    @outPorts.out.disconnect()

exports.getComponent = -> new SetPropertyValue
