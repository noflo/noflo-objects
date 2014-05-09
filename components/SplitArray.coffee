noflo = require 'noflo'

class SplitArray extends noflo.Component
  constructor: ->
    @inPorts = new noflo.InPorts
      in:
        datatype: 'all'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'all'

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (data) =>
      unless toString.call(data) is '[object Array]'
        for key, item of data
          @outPorts.out.beginGroup key
          @outPorts.out.send item
          @outPorts.out.endGroup()
        return
      @outPorts.out.send item for item in data
    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', (data) =>
      @outPorts.out.disconnect()

exports.getComponent = -> new SplitArray
