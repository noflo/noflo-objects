noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'MapProperty component', ->
  c = null
  ins = null
  map = null
  out = null

  before (done) ->
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/MapProperty', (err, instance) ->
      return done err if err
      c = instance
      done()

  beforeEach (done) ->
    ins = noflo.internalSocket.createSocket()
    map = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.map.attach map
    c.outPorts.out.attach out
    done()

  afterEach (done) ->
    c.outPorts.out.detach out
    out = null
    done()

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'map properties', ->
    o = { a:1, b:2, c:3 }

    it 'test no map', (done) ->
      c.inPorts.map.sockets = []
      output = []

      out.on "data", (data) ->
        output.push data

      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [{ a:1, b:2, c:3 }]
        done()

      ins.post new noflo.IP 'data', o

    it "test map to letter key", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [{ d:1, b:2, c:3 }]
        done()
      map.post new noflo.IP 'data', {a:"d"}
      ins.post new noflo.IP 'data', o

    it "test map to colliding key", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [{ b:[1,2], c:3 }]
        done()
      map.post new noflo.IP 'data', {a:"b"}
      ins.post new noflo.IP 'data', o

    it "test map to 0 key", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [{ 0:1, b:2, c:3 }]
        done()
      map.post new noflo.IP 'data', {a:0}
      ins.post new noflo.IP 'data', o

    it "test map to null key", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [{ null:1, b:2, c:3 }]
        done()
      map.post new noflo.IP 'data', {a:null}
      ins.post new noflo.IP 'data', o

    it "test map to undefined key", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [{ undefined:1, b:2, c:3 }]
        done()
      map.post new noflo.IP 'data', {a:undefined}
      ins.post new noflo.IP 'data', o

    it "test map to false key", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [{ false:1, b:2, c:3 }]
        done()
      map.post new noflo.IP 'data', {a:false}
      ins.post new noflo.IP 'data', o
