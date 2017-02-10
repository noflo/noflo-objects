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
      done()
  beforeEach (done) ->
    key = noflo.internalSocket.createSocket()
    reverse = noflo.internalSocket.createSocket()
    base = noflo.internalSocket.createSocket()
    c.inPorts.base.attach base
    ins = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    done()
  afterEach (done) ->
    c.inPorts.reverse.detach reverse
    c.inPorts.key.detach key
    c.outPorts.out.detach out
    done()

  describe 'with two bases and an object to extend', ->
    it 'should produce an object based on all three', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 3
          b: 2
          c: 5
          d: 6
        done()

      base.post new noflo.IP 'openBracket'
      base.post new noflo.IP 'data', object1
      base.post new noflo.IP 'data', object2
      base.post new noflo.IP 'closeBracket'

      ins.post new noflo.IP 'data', object3

  describe 'with two bases and an empty object to extend', ->
    it 'should produce an object based on the two', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 3
          b: 2
          c: 5
        done()

      base.post new noflo.IP 'openBracket'
      base.post new noflo.IP 'data', object1
      base.post new noflo.IP 'data', object2
      base.post new noflo.IP 'closeBracket'

      ins.post new noflo.IP 'data', {}

  describe 'with a "c" key for the extend', ->
    it 'should produce an object from the only matching base and the input', (done) ->
      c.inPorts.key.attach key

      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 3
          c: 5
          d: 6
        done()

      key.post new noflo.IP 'data', 'c'

      base.post new noflo.IP 'openBracket'
      base.post new noflo.IP 'data', object1
      base.post new noflo.IP 'data', object2
      base.post new noflo.IP 'closeBracket'

      ins.post new noflo.IP 'data', object3

  describe 'with key that none of the objects match', ->
    it 'should produce an object only based on input data', (done) ->
      c.inPorts.key.attach key

      out.on 'data', (data) ->
        chai.expect(data).to.eql
          c: 5
          d: 6
        done()

      key.post new noflo.IP 'data', 'norris'

      base.post new noflo.IP 'openBracket'
      base.post new noflo.IP 'data', object1
      base.post new noflo.IP 'data', object2
      base.post new noflo.IP 'closeBracket'

      ins.post new noflo.IP 'data', object3

  describe 'with no base objects (empty stream)', ->
    it 'should produce an object only based on input data', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          c: 5
          d: 6
        done()

      base.post new noflo.IP 'openBracket'
      base.post new noflo.IP 'closeBracket'
      ins.post new noflo.IP 'data', object3

  describe 'with the reverse flag set', ->
    it 'should produce the expected object', (done) ->
      c.inPorts.reverse.attach reverse
      out.on 'data', (data) ->
        chai.expect(data).to.eql
        a: 3
        b: 2
        c: 5
        d: 6
        done()

      reverse.post new noflo.IP 'data', 'true'

      base.post new noflo.IP 'openBracket'
      base.post new noflo.IP 'data', object1
      base.post new noflo.IP 'data', object2
      base.post new noflo.IP 'closeBracket'

      ins.post new noflo.IP 'data', object3
