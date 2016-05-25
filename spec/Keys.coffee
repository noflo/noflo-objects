noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'Keys component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/Keys', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'given an object', ->
    it 'should return the keys as an array', (done) ->
      expected = [
        'a'
        'b'
      ]
      out.on 'data', (data) ->
        chai.expect(data).to.equal expected.shift()
        done() unless expected.length

      ins.send
        a: 1
        b:
          c: 2
          d: [3, 4]
