noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'SetProperty component', ->
  c = null
  property = null
  inIn = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/SetProperty', (err, instance) ->
      return done err if err
      c = instance
      property = noflo.internalSocket.createSocket()
      c.inPorts.property.attach property
      inIn = noflo.internalSocket.createSocket()
      c.inPorts.in.attach inIn
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'given an empty object, property p should be set with the value 1', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          p: undefined
        done()

      property.send 'p'
      inIn.send {}
