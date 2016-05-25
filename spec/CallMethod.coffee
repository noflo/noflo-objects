noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'CallMethod component', ->
  c = null
  method = null
  args = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/CallMethod', (err, instance) ->
      return done err if err
      c = instance
      method = noflo.internalSocket.createSocket()
      args = noflo.internalSocket.createSocket()
      ins = noflo.internalSocket.createSocket()
      c.inPorts.method.attach method
      c.inPorts.arguments.attach args
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'with an input object', ->
    it 'should return a value', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.equal 3
        done()

      method.send 'getA'
      ins.send
        a: 3
        getA: -> @a

  describe 'with arguments for method', ->
    it 'should return the modified object', (done) ->
      inc = (forA, forB) ->
        @a += forA
        @b += forB
        @

      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 2
          b: 15
          inc: inc
        done()

      method.send 'inc'
      args.send 1
      args.send 5
      ins.send
        a: 1
        b: 10
        inc: inc
