noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'ReplaceKey component', ->
  c = null
  pattern = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/ReplaceKey', (err, instance) ->
      return done err if err
      c = instance
      pattern = noflo.internalSocket.createSocket()
      c.inPorts.pattern.attach pattern
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

  describe 'given a regexp', ->
    it 'should change the keys accordingly', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          def: 1
          bbc: 2
        done()

      pattern.post new noflo.IP 'data',
        'a.+c': 'def'

      ins.post new noflo.IP 'data',
        abc: 1
        bbc: 2
