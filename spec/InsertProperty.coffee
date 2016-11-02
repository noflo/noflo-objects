noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

expect = chai.expect unless expect

describe 'InsertProperty', ->

  c = null
  loader = null

  before ->
    loader = new noflo.ComponentLoader baseDir

  beforeEach (done) ->
    @timeout 4000
    loader.load 'objects/InsertProperty', (err, instance) ->
      return done err if err
      c = instance
      done()

  describe 'inPorts', ->

    it 'should include "in"', ->
      expect(c.inPorts.in).to.be.an 'object'

    it 'should include "property"', ->
      expect(c.inPorts.property).to.be.an 'object'

  describe 'outPorts', ->

    it 'should include "out"', ->
      expect(c.outPorts.out).to.be.an 'object'

  describe 'data flow', ->
    inIn = null
    propertyIn = null
    outOut = null

    beforeEach ->
      inIn = noflo.internalSocket.createSocket()
      propertyIn = noflo.internalSocket.createSocket()
      outOut = noflo.internalSocket.createSocket()

      c.inPorts.in.attach inIn
      c.inPorts.property.attach propertyIn
      c.outPorts.out.attach outOut

    describe 'with input on all ports', ->

      it 'should insert the property', (done) ->
        outOut.on 'data', (data) ->
          expect(data).to.deep.equal
            test: true
            key: 'value'
          done()

        inIn.send {test: true}

        propertyIn.beginGroup 'key'
        propertyIn.send 'value'
        propertyIn.endGroup()
