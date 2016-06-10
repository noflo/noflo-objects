noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  RemoveProperty = require '../components/RemoveProperty.coffee'
else
  RemoveProperty = require 'noflo-objects/components/RemoveProperty.js'

expect = chai.expect unless expect


describe 'RemoveProperty', ->

  c = null

  beforeEach ->
    c = RemoveProperty.getComponent()

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
      it 'should remove the property', (done) ->
        outOut.on 'data', (data) ->
          expect(data).to.deep.equal
            oh: 'canada'
          done()

        propertyIn.send 'test'
        propertyIn.send 'key'

        inIn.send
          test: true
          key: 'value'
          oh: 'canada'

