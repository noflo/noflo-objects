noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'ExtractProperty component', ->
  c = null
  key = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/ExtractProperty', (err, instance) ->
      return done err if err
      c = instance
      key = noflo.internalSocket.createSocket()
      c.inPorts.key.attach key
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  getInputObject = ->
    p: false
    n: null

  describe 'given an object, a property/key p', ->
    it 'should extract the value of that property from the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql false
        done()

      key.send 'p'
      ins.send getInputObject()

    it 'should not extract a non existant property from the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql null
        done()

      key.send 'z'
      ins.send getInputObject()
