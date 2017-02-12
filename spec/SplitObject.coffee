noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'SplitObject component', ->
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
  beforeEach (done) ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    done()
  afterEach (done) ->
    c.outPorts.out.detach out
    done()

  describe 'given an object', ->
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

      closing = 0
      out.on 'ip', (data) ->
        if data.type is 'openBracket' and data.data?
          received.push "< #{data.data}"

        if data.type is 'data' and data.data?
          received.push "DATA #{data.data}"

        if data.type is 'closeBracket'
          closing++

          received.push '>'
          if closing is 2
            chai.expect(received).to.eql expected
            done()

      ins.post new noflo.IP 'data',
        x: 1
        y: 2
