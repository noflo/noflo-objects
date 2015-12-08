noflo = require 'noflo'

addProperty = (c, out, object) ->
  object.data[c.property] = c.value
  for group in object.group
    out.beginGroup group
  out.send object.data
  for group in object.group
    out.endGroup()

addProperties = (c) ->
  addProperty object for object in c.data
  c.data = []

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'edit'
  c.description = 'Set a value to an object\'s property'

  c.property = null
  c.data = []
  c.groups = []
  c.keep = false

  c.inPorts.add 'property',
    datatype: 'string'
    description: 'Property name to set value on'
  c.inPorts.add 'value',
    datatype: 'all'
    description: 'Property value to set'
  c.inPorts.add 'in',
    datatype: 'object'
    description: 'Object to set property value on'
  c.inPorts.add 'keep',
    datatype: 'boolean'
    description: 'true if input value must be kept around, false to drop it after the value is set'

  c.outPorts.add 'out',
    datatype: 'object'
    description: 'Object forwarded from the input'

  noflo.helpers.WirePattern c,
    in: ['property', 'value', 'in']
    params: ['keep']
    out: 'out'
    forwardGroups: 'in'
    async: true
  , (payload, groups, out, callback) ->
    if c.params.keep
      c.keep = String(c.params.keep) is 'true'
    if payload.property
      c.property = payload.property
      addProperties(c) if c.value != undefined and c.data.length
      do callback
    if payload.value
      c.value = payload.value
      addProperties(c) if c.property and c.data.length
      do callback
    if payload.in
      if c.property and c.value != undefined
        addProperty c, out,
          data: payload.in
          group: groups.slice 0
        do callback
        return
      c.data.push
        data: payload.in
        group: groups.slice 0
      delete c.value unless c.keep
      do callback

  c
