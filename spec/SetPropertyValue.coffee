noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

getInputObject = ->
  JSON.parse JSON.stringify
    a: 1
    b:
      c: 2
      d: [3, 4]

describe 'SetPropertyValue component', ->
  c = null
  property = null
  value = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/SetPropertyValue', (err, instance) ->
      return done err if err
      c = instance
      property = noflo.internalSocket.createSocket()
      c.inPorts.property.attach property
      value = noflo.internalSocket.createSocket()
      c.inPorts.value.attach value
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'given an object, a property p and value 1', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 1
          b:
            c: 2
            d: [3, 4]
          p: 1
        done()

      property.send 'p'
      value.send 1
      ins.send getInputObject()

  describe 'given an object, a property p and value "test"', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 1
          b:
            c: 2
            d: [3, 4]
          p: 'test'
        done()

      property.send 'p'
      value.send 'test'
      ins.send getInputObject()

  describe 'given an object, a property p and value NULL', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 1
          b:
            c: 2
            d: [3, 4]
          p: null
        done()

      property.send 'p'
      value.send null
      ins.send getInputObject()

  describe 'given an object, a property p and value 0', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 1
          b:
            c: 2
            d: [3, 4]
          p: 0
        done()

      property.send 'p'
      value.send 0
      ins.send getInputObject()

  describe 'given an object, a property p and value FALSE', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 1
          b:
            c: 2
            d: [3, 4]
          p: false
        done()

      property.send 'p'
      value.send false
      ins.send getInputObject()
