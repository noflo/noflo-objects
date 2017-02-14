noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'Size component', ->
  c = null
  property = null
  inIn = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/Size', (err, instance) ->
      return done err if err
      c = instance
      inIn = noflo.internalSocket.createSocket()
      c.inPorts.in.attach inIn
      done()
  beforeEach (done) ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    done()
  afterEach (done) ->
    c.outPorts.out.detach out
    done()

  describe 'given an object with 3 keys', ->
    it 'should give back number 3', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql 3
        done()

      inIn.post new noflo.IP 'data', {one: 1, two: 2, three: 3}

  describe 'given an array with 2 values', ->
    it 'should give back number 2', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql 2
        done()

      inIn.post new noflo.IP 'data', [40, 2]
