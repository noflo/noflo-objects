noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'DuplicateProperty component', ->
  c = null
  ins = null
  property = null
  separator = null
  out = null

  before (done) ->
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/DuplicateProperty', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      property = noflo.internalSocket.createSocket()
      separator = noflo.internalSocket.createSocket()
      out = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      c.inPorts.property.attach property
      c.inPorts.separator.attach separator
      c.outPorts.out.attach out
      done()

  describe 'duplicate property', ->
    o = { a:1, b:2, c:3 }

    it "should duplicate property ", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.eql [ { a: 'eh', b: 2, c: 3, d: 'eh' } ]
        done()
      separator.post new noflo.IP 'data', ','
      property.post new noflo.IP 'data', 'a=d'
      property.post new noflo.IP 'closeBracket'
      ins.post new noflo.IP 'data', { a:'eh', b:2, c:3 }
      ins.post new noflo.IP 'closeBracket'