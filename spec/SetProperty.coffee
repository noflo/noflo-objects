describe 'SetProperty component', ->
  c = null
  property = null
  inIn = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/SetProperty', (err, instance) ->
      return done err if err
      c = instance
      property = noflo.internalSocket.createSocket()
      c.inPorts.property.attach property
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

  describe 'given an empty object, property p should be set', ->
    it 'should set it to the object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          p: undefined
        done()

      inIn.post new noflo.IP 'data', {}
      property.post new noflo.IP 'data', 'p'
