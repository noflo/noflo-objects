noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

expect = chai.expect unless expect

describe 'GetObjectKey', ->
  c = null

  before (done) ->
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/GetObjectKey', (err, instance) ->
      return done err if err
      c = instance
      done()

  describe 'inPorts', ->
    it 'should include "in"', (done) ->
      expect(c.inPorts.in).to.be.an 'object'
      done()
    it 'should include "key"', (done) ->
      expect(c.inPorts.key).to.be.an 'object'
      done()
    it 'should include "sendgroup"', (done) ->
      expect(c.inPorts.sendgroup).to.be.an 'object'
      done()

  describe 'outPorts', ->
    it 'should include "out"', (done) ->
      expect(c.outPorts.out).to.be.an 'object'
      done()
    it 'should include "object"', (done) ->
      expect(c.outPorts.object).to.be.an 'object'
      done()
    it 'should include "missed"', (done) ->
      expect(c.outPorts.missed).to.be.an 'object'
      done()

  describe 'data flow', ->
    inIn = null
    keyIn = null
    sendgroupIn = null
    outOut = null
    objectOut = null
    missedOut = null

    beforeEach (done) ->
      inIn = noflo.internalSocket.createSocket()
      keyIn = noflo.internalSocket.createSocket()
      objectOut = noflo.internalSocket.createSocket()
      missedOut = noflo.internalSocket.createSocket()
      outOut = noflo.internalSocket.createSocket()

      c.inPorts.in.attach inIn
      c.inPorts.key.attach keyIn
      c.outPorts.out.attach outOut
      c.outPorts.object.attach objectOut
      c.outPorts.missed.attach missedOut
      done()

    afterEach (done) ->
      c.outPorts.out.detach outOut
      c.outPorts.object.detach objectOut
      c.outPorts.missed.detach missedOut
      done()

    describe 'with input on all ports', ->
      it 'should get the key', (done) ->
        outOut.on 'data', (data) ->
          chai.expect(data).to.eql 'canada'
          done()

        objectOut.on 'data', (data) ->
          chai.expect(data).to.eql {test: true, eh: 'canada'}

        keyIn.post new noflo.IP 'data', 'eh'
        inIn.post new noflo.IP 'data', {test: true, eh: 'canada'}

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

        keyIn.post new noflo.IP 'data', 'nope'
        inIn.post new noflo.IP 'data', {test: true, eh: 'canada'}

    describe 'when using sendgroups', ->
      beforeEach (done) ->
        sendgroupIn = noflo.internalSocket.createSocket()
        c.inPorts.sendgroup.attach sendgroupIn
        done()

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

        objectOut.on 'disconnect', ->
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

        keyIn.post new noflo.IP 'data', 'eh'
        sendgroupIn.post new noflo.IP 'data', 'true'
        inIn.post new noflo.IP 'data', {test: true, eh: 'canada'}

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
          chai.expect(data).to.not.exist
        outOut.on 'endgroup', (data) ->
          hasEndGroup = true
          chai.expect(data).to.equal 'nonexistant'
          if hasMissed and hasBeginGroup and hasData and hasEndGroup
            done()

        keyIn.post new noflo.IP 'data', 'nonexistant'
        sendgroupIn.post new noflo.IP 'data', 'true'
        inIn.post new noflo.IP 'data', {test: true, eh: 'canada'}

      it 'should send groups to missed', (done) ->
        hasMissed = false
        hasMissedBeginGroup = false
        hasMissedEndGroup = false
        hasBeginGroup = false
        hasEndGroup = false
        hasData = false

        missedOut.on 'connect', (data) ->
        missedOut.on 'disconnect', (data) ->
        outOut.on 'connect', (data) ->
        outOut.on 'disconnect', (data) ->

        missedOut.on 'begingroup', (data) ->
          hasMissedBeginGroup = true
          chai.expect(data).to.eql 'nonexistant'
        missedOut.on 'endgroup', (data) ->
          hasMissedEndGroup = true
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
          chai.expect(data).to.not.exist
        outOut.on 'endgroup', (data) ->
          hasEndGroup = true
          chai.expect(data).to.eql 'nonexistant'
          if hasMissed and hasBeginGroup and hasData and hasEndGroup and hasMissedBeginGroup and hasMissedEndGroup
            done()

        keyIn.post new noflo.IP 'data', 'nonexistant'
        sendgroupIn.post new noflo.IP 'data', true
        inIn.post new noflo.IP 'data', {test: true, eh: 'canada'}

      it.skip 'should be able to handle more than one key', (done) ->
      it.skip 'should forward brackets', (done) ->
      it.skip 'should forward nested brackets', (done) ->
