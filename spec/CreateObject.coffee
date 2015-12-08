noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  CreateObject = require '../components/CreateObject.coffee'
else
  CreateObject = require 'noflo-objects/components/CreateObject.js'

expect = chai.expect unless expect

describe 'CreateObject', ->
  c = null

  beforeEach ->
    c = CreateObject.getComponent()

  describe 'inPorts', ->
    it 'should include "start"', ->
      expect(c.inPorts.start).to.be.an 'object'

  describe 'outPorts', ->
    it 'should include "out"', ->
      expect(c.outPorts.out).to.be.an 'object'

  describe 'data flow', ->
    start = null
    out = null

    beforeEach ->
      start = noflo.internalSocket.createSocket()
      out = noflo.internalSocket.createSocket()

      c.inPorts.start.attach start
      c.outPorts.out.attach out

    describe 'when start', ->
      it 'should create a new empty object', (done) ->
        groups = []
        out.on 'begingroup', (group) ->
          groups.push group
        out.on 'endgroup', ->
          groups.pop()
        out.on 'data', (data) ->
          expect(data).to.deep.equal {}
          expect(groups[0]).to.equal 'foo'
          done()
        start.beginGroup 'foo'
        start.send 'bang'
        start.endGroup()
