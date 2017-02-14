noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'UniqueArray component', ->
  c = null
  property = null
  inIn = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/UniqueArray', (err, instance) ->
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

  describe 'given an array with 3 items, with a duplicate', ->
    it 'should give an array with only 2', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql ['0', '1']
        done()

      inIn.post new noflo.IP 'data', [0, 1, 1]
