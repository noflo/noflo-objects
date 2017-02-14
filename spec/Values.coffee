noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'Values component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/Values', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach (done) ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    done()
  afterEach (done) ->
    c.outPorts.out.detach out
    done()

  describe 'given an object', ->
    it 'should return the values as an array', (done) ->
      expected = [
        1
      ,
        c: 2
        d: [3, 4]
      ]
      out.on 'data', (data) ->
        chai.expect(data).to.eql expected.shift()
        done() unless expected.length

      ins.post new noflo.IP 'data',
        a: 1
        b:
          c: 2
          d: [3, 4]
