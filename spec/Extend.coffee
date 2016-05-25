noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'Extend component', ->
  c = null
  key = null
  reverse = null
  base = null
  ins = null
  out = null

  object1 =
    a: 1
    b: 2
  object2 =
    a: 3
    c: 5
  object3 =
    c: 5
    d: 6

  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/Extend', (err, instance) ->
      return done err if err
      c = instance
      key = noflo.internalSocket.createSocket()
      c.inPorts.key.attach key
      reverse = noflo.internalSocket.createSocket()
      c.inPorts.reverse.attach reverse
      base = noflo.internalSocket.createSocket()
      c.inPorts.base.attach base
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out
    key.send null
    reverse.send false
    base.disconnect()

  describe 'with two bases and an object to extend', ->
    it 'should produce an object based on all three', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 3
          b: 2
          c: 5
          d: 6
        done()

      base.send object1
      base.send object2

      ins.send object3

  describe 'with two bases and an empty object to extend', ->
    it 'should produce an object based on the two', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 3
          b: 2
          c: 5
        done()

      base.send object1
      base.send object2

      ins.send {}

  describe 'with a "c" key for the extend', ->
    it 'should produce an object from the only matching base and the input', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 3
          c: 5
          d: 6
        done()

      key.send 'c'

      base.send object1
      base.send object2

      ins.send object3

  describe 'with key that none of the objects match', ->
    it 'should produce an object only based on input data', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          c: 5
          d: 6
        done()

      key.send 'norris'

      base.send object1
      base.send object2

      ins.send object3

  describe 'with no base objects', ->
    it 'should produce an object only based on input data', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          c: 5
          d: 6
        done()

      ins.send object3

  describe 'with the reverse flag set', ->
    it 'should produce the expected object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
        a: 3
        b: 2
        c: 5
        d: 6
        done()

      base.send object1
      base.send object2

      ins.send object3
