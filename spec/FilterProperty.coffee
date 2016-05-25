noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'FilterProperty component', ->
  c = null
  recurse = null
  keep = null
  key = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/FilterProperty', (err, instance) ->
      return done err if err
      c = instance
      recurse = noflo.internalSocket.createSocket()
      keep = noflo.internalSocket.createSocket()
      key = noflo.internalSocket.createSocket()
      ins = noflo.internalSocket.createSocket()
      c.inPorts.recurse.attach recurse
      c.inPorts.keep.attach keep
      c.inPorts.key.attach key
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'with properties to filter', ->
    it 'should return the filtered objects', (done) ->
      expected = [
        b: 2
      ,
        b: 4
      ]
      out.on 'data', (data) ->
        chai.expect(data).to.eql expected.shift()
        done() unless expected.length

      key.send 'a'
      key.send 'c.+'
      key.disconnect()

      ins.send
        a: 1
        b: 2
      ins.send
        cat: 3
        b: 4

  describe 'with keep set to true', ->
    it 'should return the filtered objects', (done) ->
      expected = [
        {}
      ,
        cat: 3
      ]
      out.on 'data', (data) ->
        chai.expect(data).to.eql expected.shift()
        return if expected.length
        keep.send false
        done()

      keep.send true
      key.send 'a.+'
      key.disconnect()

      ins.send
        a: 1
        b: 2
      ins.send
        cat: 3
        b: 4

  describe 'recursively filtering', ->
    it 'should return the filtered key/value pair', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          x:
            b: 2
            y: {}
        recurse.send false
        done()

      recurse.send true
      key.send 'a'
      key.send 'c'
      key.disconnect()

      ins.send
        x:
          a: 1
          b: 2
          y:
            c: 3
