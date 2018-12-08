getInputObject = ->
  JSON.parse JSON.stringify
    a: 1
    b:
      c: 2
      d: [3, 4]

describe 'SetPropertyValue component', ->
  c = null
  property = null
  value = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/SetPropertyValue', (err, instance) ->
      return done err if err
      c = instance
      property = noflo.internalSocket.createSocket()
      c.inPorts.property.attach property
      value = noflo.internalSocket.createSocket()
      c.inPorts.value.attach value
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

  describe 'given an object, a property p and value 1', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 1
          b:
            c: 2
            d: [3, 4]
          p: 1
        done()

      property.post new noflo.IP 'data', 'p'
      value.post new noflo.IP 'data', 1
      ins.post new noflo.IP 'data', getInputObject()

  describe 'given an object, a property p and value "test"', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 1
          b:
            c: 2
            d: [3, 4]
          p: 'test'
        done()

      property.post new noflo.IP 'data', 'p'
      value.post new noflo.IP 'data', 'test'
      ins.post new noflo.IP 'data', getInputObject()

  describe 'given an object, a property p and value NULL', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 1
          b:
            c: 2
            d: [3, 4]
          p: null
        done()

      property.post new noflo.IP 'data', 'p'
      value.post new noflo.IP 'data', null
      ins.post new noflo.IP 'data', getInputObject()

  describe 'given an object, a property p and value 0', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 1
          b:
            c: 2
            d: [3, 4]
          p: 0
        done()

      property.post new noflo.IP 'data', 'p'
      value.post new noflo.IP 'data', 0
      ins.post new noflo.IP 'data', getInputObject()

  describe 'given an object, a property p and value FALSE', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 1
          b:
            c: 2
            d: [3, 4]
          p: false
        done()

      property.post new noflo.IP 'data', 'p'
      value.post new noflo.IP 'data', false
      ins.post new noflo.IP 'data', getInputObject()
