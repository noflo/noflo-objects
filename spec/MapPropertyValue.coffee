noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  MapPropertyValue = require '../components/MapPropertyValue.coffee'
else
  MapPropertyValue = require 'noflo-objects/components/MapPropertyValue.js'

describe 'MapPropertyValue component', ->
  c = null
  ins = null
  map = null
  out = null

  beforeEach ->
    c = MapPropertyValue.getComponent()
    ins = noflo.internalSocket.createSocket()
    map = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.map.attach map
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.in).to.be.an 'object'

    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'map properties', ->
    o = { a:1, b:2, c:3 }

    it 'should work with no map', (done) ->
      output = []

      out.on "data", (data) ->
        output.push data

      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [{ a:1, b:2, c:3 }]
        done()

      ins.send o
      ins.disconnect()

    it "should map from to with object", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [ { a: 'canada', b: 2, c: 3 } ]
        done()
      map.send {eh:'canada'}
      map.disconnect
      ins.send { a:'eh', b:2, c:3 }
      ins.disconnect()

    it "should map from to with string", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [ { a: "0", b: 2, c: 3 } ]
        done()
      map.send '1=0'
      map.disconnect()
      ins.send o
      ins.disconnect()
