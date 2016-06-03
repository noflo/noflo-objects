noflo = require "noflo"
_ = require "underscore"
{ deepCopy } = require "owl-deepcopy"

class FilterProperty extends noflo.Component

  icon: 'filter'

  description: "Filter out some properties by matching RegExps
  against the keys of incoming objects"

  constructor: ->
    @keys = []
    @recurse = false
    @keep = false

    @legacy = false
    # Legacy mode
    @accepts = []
    @regexps = []

    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Object to filter properties from'
      key:
        datatype: 'string'
        description: 'Keys to filter (one key per IP)'
      recurse:
        datatype: 'boolean'
        description: '"true" to recurse on the object\'s values'
      keep:
        datatype: 'boolean'
        description: '"true" if matching properties must be kept, otherwise removed'
      # Legacy mode
      accept:
        datatype: 'all'
      regexp:
        datatype: 'all'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'

    @inPorts.keep.on "data", (keep) =>
      @keep = String(keep) is "true"

    @inPorts.recurse.on "data", (data) =>
      @recurse = String(data) is "true"

    @inPorts.key.on "connect", =>
      @keys = []
    @inPorts.key.on "data", (key) =>
      @keys.push new RegExp key, "g"

    # Legacy mode
    @inPorts.accept.on "data", (data) =>
      @legacy = true
      @accepts.push data
    @inPorts.regexp.on "data", (data) =>
      @legacy = true
      @regexps.push data

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup group

    @inPorts.in.on "data", (data) =>
      # Legacy mode
      if @legacy
        @filterData data
      else
        if _.isObject data
          data = deepCopy data
          @filter data
          @outPorts.out.send data

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

  filter: (object) ->
    return if _.isEmpty object

    for key, value of object
      isMatched = false

      for filter in @keys
        match = key.match filter
        if not @keep and match or
           @keep and not match
          delete object[key]
          isMatched = true
          break

      if not isMatched and _.isObject(value) and @recurse
        @filter value

  # Legacy mode
  filterData: (object) ->
    newData = {}
    match = false
    for property, value of object
      if @accepts.indexOf(property) isnt -1
        newData[property] = value
        match = true
        continue

      for expression in @regexps
        regexp = new RegExp expression
        if regexp.exec property
          newData[property] = value
          match = true

    return unless match
    @outPorts.out.send newData

exports.getComponent = -> new FilterProperty