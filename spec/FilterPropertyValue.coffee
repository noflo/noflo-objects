describe 'FilterPropertyValue component', ->
  c = null
  ins = null
  out = null
  loader = null

  before ->
    loader = new noflo.ComponentLoader baseDir

  beforeEach (done) ->
    @timeout 4000
    loader.load 'objects/FilterPropertyValue', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      out = noflo.internalSocket.createSocket()
      c.outPorts.out.attach out
      done()

  afterEach (done) ->
    c.outPorts.out.detach out
    out = null
    done()

  it 'should have input ports', (done) ->
    chai.expect(c.inPorts.in).to.be.an 'object'
    done()
  it 'should have an output port', (done) ->
    chai.expect(c.outPorts.out).to.be.an 'object'
    done()

  it 'test default behavior', (done) ->
    actual = [{a:1},{b:2},{c:3}]
    expect = [{a:1},{b:2},{c:3}]

    out.on "data", (data) ->
      expected = expect.shift()
      chai.expect((Object.keys data).length).to.equal (Object.keys expected).length
      chai.expect(val).to.equal expected[prop] for prop, val of data
      done() if expect.length == 0

    ins.post new noflo.IP 'openBracket'
    ins.post new noflo.IP 'data', a for a in actual
    ins.post new noflo.IP 'closeBracket'

  it 'test accept via map', (done) ->
    acc = noflo.internalSocket.createSocket()
    c.inPorts.accept.attach acc

    acc.post new noflo.IP 'openBracket'
    acc.post new noflo.IP 'data', { good: true }
    acc.post new noflo.IP 'closeBracket'

    out.on "data", (data) ->
      chai.expect(data.good).to.equal true
      chai.expect(data.bar).to.equal 3
      chai.expect((k for k of data).length).to.equal 2
      done()

    ins.post new noflo.IP 'openBracket'
    ins.post new noflo.IP 'data', { good: false, foo: 1 } # reject
    ins.post new noflo.IP 'data', { baz: 2 }              # reject
    ins.post new noflo.IP 'data', { good: true, bar: 3 }  # accept
    ins.post new noflo.IP 'closeBracket'

  it 'test accept via pairs', (done) ->
    acc = noflo.internalSocket.createSocket()
    c.inPorts.accept.attach acc

    acc.post new noflo.IP 'openBracket'
    acc.post new noflo.IP 'data', "food=true"
    acc.post new noflo.IP 'data', "good=yes"
    acc.post new noflo.IP 'data', "hood=1"
    acc.post new noflo.IP 'closeBracket'

    expect = [["good","yes"],["hood",1],["food",true]]

    out.on "data", (data) ->
      exp = expect.shift()
      chai.expect(data[exp[0]]).to.equal exp[1]
      done() if expect.length is 0

    ins.post new noflo.IP 'openBracket'
    ins.post new noflo.IP 'data', { good: "yes" }         # accept
    ins.post new noflo.IP 'data', { hood: 1 }             # accept
    ins.post new noflo.IP 'data', { good: false, foo: 1 } # reject
    ins.post new noflo.IP 'data', { baz: 2 }              # reject
    ins.post new noflo.IP 'data', { food: true, bar: 3 }  # accept
    ins.post new noflo.IP 'closeBracket'

  it 'test accept via regexp', (done) ->
    reg = noflo.internalSocket.createSocket()
    c.inPorts.regexp.attach reg
    acc = noflo.internalSocket.createSocket()
    c.inPorts.accept.attach acc

    acc.post new noflo.IP 'data', {}
    reg.post new noflo.IP 'data', "good=[tg]rue"

    expect = ["grue",true]

    out.on "data", (data) ->
      chai.expect(data.good).to.equal expect.shift()
      chai.expect(data.bar).to.equal 3
      chai.expect((k for k of data).length).to.equal 2
      done() if expect.length is 0

    ins.post new noflo.IP 'openBracket'
    ins.post new noflo.IP 'data', { good: "grue", bar: 3 } # accept
    ins.post new noflo.IP 'data', { good: false, foo: 1 }  # reject
    ins.post new noflo.IP 'data', { baz: 2 }               # reject
    ins.post new noflo.IP 'data', { good: true, bar: 3 }   # accept
    ins.post new noflo.IP 'closeBracket'
