noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  SetPropertyValue = require '../components/SetPropertyValue.coffee'
else
  SetPropertyValue = require 'noflo-objects/components/SetPropertyValue.js'

expect = chai.expect unless expect

describe 'SetPropertyValue', ->
  c = null

  beforeEach ->
    c = SetPropertyValue.getComponent()

  describe 'inPorts', ->
    it 'should include "in"', ->
      expect(c.inPorts.in).to.be.an 'object'
    it 'should include "property"', ->
      expect(c.inPorts.property).to.be.an 'object'
    it 'should include "value"', ->
      expect(c.inPorts.value).to.be.an 'object'
    it 'should include "keep"', ->
      expect(c.inPorts.keep).to.be.an 'object'

  describe 'outPorts', ->
    it 'should include "out"', ->
      expect(c.outPorts.out).to.be.an 'object'

  describe 'data flow', ->
    inIn = null
    propertyIn = null
    valueIn = null
    keepIn = null
    outOut = null

    beforeEach ->
      inIn = noflo.internalSocket.createSocket()
      propertyIn = noflo.internalSocket.createSocket()
      valueIn = noflo.internalSocket.createSocket()
      keepIn = noflo.internalSocket.createSocket()
      outOut = noflo.internalSocket.createSocket()

      c.inPorts.in.attach inIn
      c.inPorts.property.attach propertyIn
      c.inPorts.value.attach valueIn
      c.inPorts.keep.attach keepIn
      c.outPorts.out.attach outOut

    describe 'with input on all ports', ->
      it 'should insert the property', (done) ->
        outOut.on 'data', (data) ->
          expect(data).to.deep.equal
            foo: false
            bar: 42
          done()
        inIn.send
          foo: true
          bar: 42
        propertyIn.send 'foo'
        valueIn.send false
