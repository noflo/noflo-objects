noflo = require 'noflo'

class SetPropertyValue extends noflo.Component
  constructor: ->
    @property = null
    @value = null
    @data = []
    @groups = []
    @keep = false

    @inPorts =
      property: new noflo.Port 'string'
      value: new noflo.Port 'all'
      in: new noflo.Port 'object'
      # Persist value
      keep: new noflo.Port 'boolean'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.keep.on 'data', (keep) =>
      @keep = String(keep) is 'true'

    @inPorts.property.on 'data', (data) =>
      @property = data
      @addProperties() if @value and @data.length
    @inPorts.value.on 'data', (data) =>
      @value = data
      @addProperties() if @property and @data.length

    @inPorts.in.on 'begingroup', (group) =>
      @groups.push group
    @inPorts.in.on 'data', (data) =>
      if @property and @value
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
      @outPorts.out.disconnect() if @property and @value
      @value = null unless @keep

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
