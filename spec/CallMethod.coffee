describe 'CallMethod component', ->
  c = null
  method = null
  args = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/CallMethod', (err, instance) ->
      return done err if err
      c = instance
      done()
  beforeEach (done) ->
    method = noflo.internalSocket.createSocket()
    args = noflo.internalSocket.createSocket()
    ins = noflo.internalSocket.createSocket()
    c.inPorts.method.attach method
    c.inPorts.in.attach ins
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    done()
  afterEach (done) ->
    c.inPorts.arguments.detach args
    c.outPorts.out.detach out
    done()

  describe 'with an input object', ->
    it 'should return a value', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.equal 3
        done()

      method.post new noflo.IP 'data', 'getA'
      ins.post new noflo.IP 'data',
        a: 3
        getA: -> @a

  describe 'with arguments for method', ->
    it 'should return the modified object', (done) ->
      c.inPorts.arguments.attach args
      inc = (forA, forB) ->
        @a += forA
        @b += forB
        @

      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a: 2
          b: 15
          inc: inc
        done()

      method.post new noflo.IP 'data', 'inc'
      args.post new noflo.IP 'openBracket'
      args.post new noflo.IP 'data', 1
      args.post new noflo.IP 'data', 5
      args.post new noflo.IP 'closeBracket'
      ins.post new noflo.IP 'data',
        a: 1
        b: 10
        inc: inc
