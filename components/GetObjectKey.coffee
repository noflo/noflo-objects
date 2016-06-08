noflo = require 'noflo'

class GetObjectKey extends noflo.Component
  icon: 'indent'
  constructor: ->
    @sendGroup = true
    @groups = []
    @data = []
    @key = []
    @errored = false

    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Object to get keys from'
        required: true
      key:
        datatype: 'string'
        description: 'Keys to extract from the object (one key per IP)'
        required: true
      sendgroup:
        datatype: 'boolean'
        description: 'true to send keys as groups around value IPs, false otherwise'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'all'
        description: 'Values extracts from the input object given the input keys (one value per IP, potentially grouped using the key names)'
      object:
        datatype: 'object'
        description: 'Object forwarded from input if at least one property matches the input keys'
      missed:
        datatype: 'object'
        description: 'Object forwarded from input if no property matches the input keys'

    @inPorts.in.on 'connect', =>
      @data = []
    @inPorts.in.on 'begingroup', (group) =>
      @groups.push group
    @inPorts.in.on 'data', (data) =>
      if @key.length
        @getKey
          data: data
          groups: @groups
        return
      @data.push
        data: data
        groups: @groups.slice 0
    @inPorts.in.on 'endgroup', =>
      @groups.pop()

    @inPorts.in.on 'disconnect', =>
      unless @data.length
        # Data already sent
        @outPorts.out.disconnect()
        @outPorts.object.disconnect()
        return

      # No key, data will be sent when we get it
      return unless @key.length

      # Otherwise send data we have an disconnect
      @getKey data for data in @data
      @outPorts.out.disconnect()
      @outPorts.object.disconnect()

    @inPorts.key.on 'data', (data) =>
      @key.push data
    @inPorts.key.on 'disconnect', =>
      return unless @data.length

      @getKey data for data in @data
      @data = []
      @outPorts.out.disconnect()
      @outPorts.object.disconnect()

    @inPorts.sendgroup.on 'data', (data) =>
      @sendGroup = String(data) is 'true'

  error: (data, error, key, groups) ->
    @outPorts.missed.beginGroup group for group in groups
    @outPorts.missed.beginGroup key if @sendGroup

    @outPorts.missed.send data
    @outPorts.missed.disconnect()

    @outPorts.missed.endGroup() if @sendGroup
    @outPorts.missed.endGroup() for group in groups

    @errored = true

  getKey: ({data, groups}) ->
    unless @key.length
      @error data, new Error 'Key not defined'
      return
    unless typeof data is 'object'
      @error data, new Error 'Data is not an object'
      return
    if data is null
      @error data, new Error 'Data is NULL'
      return
    for key in @key
      if data[key] is undefined
        @error data, new Error("Object has no key #{key}"), key, groups

      @outPorts.out.beginGroup group for group in groups
      @outPorts.out.beginGroup key if @sendGroup
      @outPorts.out.send data[key]
      @outPorts.out.endGroup() if @sendGroup
      @outPorts.out.endGroup() for group in groups

    if @errored
      @errored = false
      return

    @outPorts.object.beginGroup group for group in groups
    @outPorts.object.send data
    @outPorts.object.endGroup() for group in groups

exports.getComponent = -> new GetObjectKey
