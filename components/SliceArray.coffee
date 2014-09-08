noflo = require 'noflo'

class SliceArray extends noflo.Component
  constructor: ->
    @begin = 0
    @end = null

    @inPorts = new noflo.InPorts
      in:
        datatype: 'array'
        description: 'Array to slice'
      begin:
        datatype: 'number'
        description: 'Beginning of the slicing'
      end:
        datatype: 'number'
        description: 'End of the slicing'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'array'
        description: 'Result of the slice operation'
      error:
        datatype: 'string'

    @inPorts.begin.on 'data', (data) =>
      @begin = data
    @inPorts.end.on 'data', (data) =>
      @end = data

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (data) =>
      @sliceData data
    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

  sliceData: (data) ->
    unless data.slice
      return @outPorts.error.send "Data #{typeof data} cannot be sliced"
    sliced = data.slice @begin, @end unless @end is null
    sliced = data.slice @begin if @end is null
    @outPorts.out.send sliced

exports.getComponent = -> new SliceArray
