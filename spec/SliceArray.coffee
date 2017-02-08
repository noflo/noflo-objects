noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

expect = chai.expect unless expect

describe 'SliceArray', ->
  c = null
  inIn = null
  begin = null
  end = null
  out = null
  errorOut = null

  before (done) ->
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/SliceArray', (err, instance) ->
      return done err if err
      c = instance
      done()

  beforeEach (done) ->
    inIn = noflo.internalSocket.createSocket()
    begin = noflo.internalSocket.createSocket()
    end = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    errorOut = noflo.internalSocket.createSocket()
    c.inPorts.in.attach inIn
    c.inPorts.begin.attach begin
    c.inPorts.end.attach end
    c.outPorts.out.attach out
    c.outPorts.error.attach errorOut
    done()

  describe 'ports', ->
    describe 'inPorts', ->
      it 'should include "in"', ->
        expect(c.inPorts.in).to.be.an 'object'
      it 'should include "begin"', ->
        expect(c.inPorts.begin).to.be.an 'object'
      it 'should include "end"', ->
        expect(c.inPorts.end).to.be.an 'object'
    describe 'outPorts', ->
      it 'should include "out"', ->
        expect(c.outPorts.out).to.be.an 'object'
      it 'should include "error"', ->
        expect(c.outPorts.out).to.be.an 'object'

  describe 'slicing an array', ->
    it 'should not work with a non array data sent to in', (done) ->
      out.on 'data', (data) ->
        throw new Error('should not go into out')

      errorOut.on 'data', (data) ->
        done()

      begin.send ''
      inIn.send null

    it 'should work with an array using 1 as begin', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql ['eh']
        done()

      begin.send 1
      inIn.send ['canada', 'eh']

    it 'should work with an array using 1 as begin and 3 as end', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql ['eh', 'igloo']
        done()

      end.send 3
      begin.send 1
      inIn.send ['canada', 'eh', 'igloo', 'moose', 'syrup']
