noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  GetObjectKey = require '../components/GetObjectKey.coffee'
else
  GetObjectKey = require 'noflo-objects/components/GetObjectKey.js'

expect = chai.expect unless expect

describe 'GetObjectKey', ->
  c = null

  beforeEach ->
    c = GetObjectKey.getComponent()

  describe 'inPorts', ->
    it 'should include "in"', ->
      expect(c.inPorts.in).to.be.an 'object'

    it 'should include "key"', ->
      expect(c.inPorts.key).to.be.an 'object'

    it 'should include "sendgroup"', ->
      expect(c.inPorts.sendgroup).to.be.an 'object'

  describe 'outPorts', ->
    it 'should include "out"', ->
      expect(c.outPorts.out).to.be.an 'object'

    it 'should include "object"', ->
      expect(c.outPorts.object).to.be.an 'object'

    it 'should include "missed"', ->
      expect(c.outPorts.missed).to.be.an 'object'

  describe 'data flow', ->
    inIn = null
    keyIn = null
    sendgroupIn = null
    outOut = null
    objectOut = null
    missedOut = null

    beforeEach ->
      inIn = noflo.internalSocket.createSocket()
      keyIn = noflo.internalSocket.createSocket()
      sendgroupIn = noflo.internalSocket.createSocket()
      objectOut = noflo.internalSocket.createSocket()
      missedOut = noflo.internalSocket.createSocket()
      outOut = noflo.internalSocket.createSocket()

      c.inPorts.in.attach inIn
      c.inPorts.key.attach keyIn
      c.inPorts.sendgroup.attach sendgroupIn
      c.outPorts.out.attach outOut
      c.outPorts.object.attach objectOut
      c.outPorts.missed.attach missedOut

    describe 'with input on all ports', ->
      it 'should get the key', (done) ->
        outOut.on 'data', (data) ->
          chai.expect(data).to.eql 'canada'
          done()

        objectOut.on 'data', (data) ->
          chai.expect(data).to.eql {test: true, eh: 'canada'}

        keyIn.send 'eh'
        inIn.send {test: true, eh: 'canada'}

    describe 'when it has data that will miss', ->
      it 'should trigger missed and not send object out as well', (done) ->
        triggeredOut = false
        triggeredMissed = false
        outOut.on 'data', (data) ->
          triggeredOut = true
          if triggeredMissed and triggeredOut
            done()

        objectOut.on 'data', (data) ->
          throw new Error('sent out object when it missed!')

        missedOut.on 'data', (data) ->
          triggeredMissed = true

        keyIn.send 'nope'
        inIn.send {test: true, eh: 'canada'}

    describe 'when using sendgroups', ->
      it 'should trigger output', (done) ->
        hasObject = false
        hasBeginGroup = false
        hasEndGroup = false
        hasData = false

        missedOut.on 'data', (data) ->
          throw new Error('went into missed')

        objectOut.on 'data', (data) ->
          hasObject = true
          chai.expect(data).to.eql {test: true, eh: 'canada'}
          if hasObject and hasBeginGroup and hasData and hasEndGroup
            done()

        outOut.on 'begingroup', (data) ->
          hasBeginGroup = true
          chai.expect(data).to.eql 'eh'
        outOut.on 'data', (data) ->
          hasData = true
          chai.expect(data).to.eql 'canada'
        outOut.on 'endgroup', (data) ->
          hasEndGroup = true
          chai.expect(data).to.eql 'eh'

        keyIn.send 'eh'
        sendgroupIn.send true
        inIn.send {test: true, eh: 'canada'}

      it 'should not trigger object when it misses, but should trigger missed and out', (done) ->
        hasMissed = false
        hasBeginGroup = false
        hasEndGroup = false
        hasData = false

        missedOut.on 'data', (data) ->
          hasMissed = true
          chai.expect(data).to.eql {test: true, eh: 'canada'}

        objectOut.on 'data', (data) ->
          throw new Error('sent out object when it missed!')

        outOut.on 'begingroup', (data) ->
          hasBeginGroup = true
          chai.expect(data).to.eql 'nonexistant'
        outOut.on 'data', (data) ->
          hasData = true
          chai.expect(data).to.eql null
        outOut.on 'endgroup', (data) ->
          hasEndGroup = true
          chai.expect(data).to.eql 'nonexistant'
          if hasMissed and hasBeginGroup and hasData and hasEndGroup
            done()

        keyIn.send 'nonexistant'
        sendgroupIn.send true
        inIn.send {test: true, eh: 'canada'}
