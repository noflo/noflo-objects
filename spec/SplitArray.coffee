noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'SplitArray component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/SplitObject', (err, instance) ->
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

  describe 'given an object (even though it is SplitArray)...', ->
    it 'should return keys as groups and values as their own IPs', (done) ->
      expected = [
        '< x'
        'DATA 1'
        '>'
        '< y'
        'DATA 2'
        '>'
      ]
      received = []

      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      ins.send
        x: 1
        y: 2
      ins.disconnect()

  describe 'given an array', ->
    it 'should return values as their own IPs', (done) ->
      expected = [
        'DATA 1'
        'DATA 2'
      ]
      received = []

      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      ins.send [1, 2]
      ins.disconnect()
