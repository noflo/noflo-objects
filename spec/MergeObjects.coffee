noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'MergeObjects component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/MergeObjects', (err, instance) ->
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

  describe 'when receiving two objects', ->
    it 'should produce a merged object on disconnect', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          x: 7
          y: [2, 3, 4, 8, 9]
          z:
            p: 10
            q: 6
            r: 11
        done()

      ins.send
        x: 1
        y: [2, 3, 4]
        z:
          p: 5
          q: 6
      ins.send
        x: 7
        y: [8, 9]
        z:
          p: 10
          r: 11
      ins.disconnect()
