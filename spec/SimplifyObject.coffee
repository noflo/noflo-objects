noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'SimplifyObject component', ->
  c = null
  property = null
  inIn = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/SimplifyObject', (err, instance) ->
      return done err if err
      c = instance
      inIn = noflo.internalSocket.createSocket()
      c.inPorts.in.attach inIn
      done()
  beforeEach (done) ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    done()
  afterEach (done) ->
    c.outPorts.out.detach out
    done()

  describe 'given an object with a $data key', ->
    it 'should give back the value', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'value'
        done()

      inIn.post new noflo.IP 'data', {'$data': 'value'}

  describe 'given an object with a normal key', ->
    it 'should give back the object as it was', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql {test: 'value'}
        done()

      inIn.post new noflo.IP 'data', {test: 'value'}

  describe 'given an array with 2 items', ->
    it 'should give back the array as it was', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql ['value', 'canada']
        done()

      inIn.post new noflo.IP 'data', ['value', 'canada']

  describe 'given an array with 1 item', ->
    it 'should give back the value', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'value'
        done()

      inIn.post new noflo.IP 'data', ['value']
