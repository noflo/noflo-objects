describe 'Join', ->
  c = null
  inIn = null
  delimiter = null
  out = null
  errorOut = null

  before (done) ->
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/Join', (err, instance) ->
      return done err if err
      c = instance
      done()

  beforeEach (done) ->
    inIn = noflo.internalSocket.createSocket()
    delimiter = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    errorOut = noflo.internalSocket.createSocket()
    c.inPorts.in.attach inIn
    c.outPorts.out.attach out
    c.outPorts.error.attach errorOut
    done()

  afterEach (done) ->
    c.inPorts.delimiter.detach delimiter
    c.outPorts.out.detach out
    c.outPorts.error.detach errorOut
    done()

  describe 'Joining an object to a string', ->
    it 'should work with an object without a specified delimiter', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql 'canada,igloo'
        done()

      inIn.post new noflo.IP 'data', {eh: 'canada', moose: 'igloo'}

    it 'should work with an object with specified delimiter', (done) ->
      c.inPorts.delimiter.attach delimiter
      out.on 'data', (data) ->
        chai.expect(data).to.eql 'canada/igloo'
        done()

      delimiter.post new noflo.IP 'data', '/'
      inIn.post new noflo.IP 'data', {eh: 'canada', moose: 'igloo'}

    it 'should not work with a non object', (done) ->
      errorOut.on 'data', (data) ->
        done()

      out.on 'data', (data) ->
        throw new Error('should not trigger out')

      inIn.post new noflo.IP 'data', null
