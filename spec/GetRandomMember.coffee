noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'GetRandomMember component', ->
  c = null
  ins = null
  random = null
  out = null
  error = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/GetRandomMember', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      random = noflo.internalSocket.createSocket()
      c.inPorts.random.attach random
      c.start done
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    error = noflo.internalSocket.createSocket()
    c.outPorts.error.attach error
  afterEach ->
    c.outPorts.out.detach out
    out = null
    c.outPorts.error.detach error
    error = null

  describe 'with an array', ->
    it 'should send first member when random is 0', (done) ->
      expected = [
        '1'
      ]
      received = []
      out.on 'ip', (ip) ->
        switch ip.type
          when 'openBracket'
            received.push '<'
          when 'data'
            received.push JSON.stringify ip.data
          when 'closeBracket'
            received.push '>'
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      ins.send [1, 2, 3]
      random.send 0
    it 'should send last member when random is 1', (done) ->
      expected = [
        '3'
      ]
      received = []
      out.on 'ip', (ip) ->
        switch ip.type
          when 'openBracket'
            received.push '<'
          when 'data'
            received.push JSON.stringify ip.data
          when 'closeBracket'
            received.push '>'
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      ins.send [1, 2, 3]
      random.send 1
    it 'should send a member when receiving random', (done) ->
      arr = [1, 2, 3, 4, 5]
      out.on 'ip', (ip) ->
        return unless ip.type is 'data'
        chai.expect(arr).to.contain ip.data
        done()
      ins.send arr
      random.send Math.random()
    it 'should forward brackets', (done) ->
      expected = [
        '<'
        '3'
        '>'
      ]
      received = []
      out.on 'ip', (ip) ->
        switch ip.type
          when 'openBracket'
            received.push '<'
          when 'data'
            received.push JSON.stringify ip.data
          when 'closeBracket'
            received.push '>'
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      ins.beginGroup()
      ins.send [1, 2, 3]
      ins.endGroup()
      random.send 1
    it 'should send an error with out-of-range random', (done) ->
      error.on 'ip', (ip) ->
        chai.expect(ip.data).to.be.an 'error'
        chai.expect(ip.data.message).to.contain 'has to be between'
        done()
      out.on 'ip', (ip) ->
        done new Error "Unexpected #{ip.type} received"
      ins.send [1, 2, 3]
      random.send -1
