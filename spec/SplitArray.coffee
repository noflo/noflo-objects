describe 'SplitArray component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/SplitArray', (err, instance) ->
      return done err if err
      c = instance
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

  describe 'given an object (even though it is SplitArray)...', ->
    it 'should return keys as groups and values as their own IPs', (done) ->
      expected = [
        '< x'
        'DATA 1'
        '>'
        '< y'
        'DATA 2'
        '>'
      ]
      received = []

      closing = 0
      out.on 'ip', (ip) ->
        if ip.type is 'openBracket'
          received.push "< #{ip.data}"

        if ip.type is 'data'
          received.push "DATA #{ip.data}"

        if ip.type is 'closeBracket'
          closing++
          received.push '>'
          if closing is 2
            chai.expect(received).to.eql expected
            done()

      ins.post new noflo.IP 'data',
        x: 1
        y: 2

  describe 'given an array', ->
    it 'should return values as their own IPs', (done) ->
      expected = [
        'DATA 1'
        'DATA 2'
      ]
      received = []

      out.on 'ip', (ip) ->
        if ip.type is 'data'
          received.push "DATA #{ip.data}"
        if ip.type is 'closeBracket'
          chai.expect(received).to.eql expected
          done()

      ins.post new noflo.IP 'data', [1, 2]
