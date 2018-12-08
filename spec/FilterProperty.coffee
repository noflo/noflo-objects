describe 'FilterProperty component', ->
  c = null
  recurse = null
  keep = null
  key = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/FilterProperty', (err, instance) ->
      return done err if err
      c = instance
      done()
  beforeEach (done) ->
    recurse = noflo.internalSocket.createSocket()
    keep = noflo.internalSocket.createSocket()
    key = noflo.internalSocket.createSocket()
    ins = noflo.internalSocket.createSocket()
    c.inPorts.key.attach key
    c.inPorts.in.attach ins
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    done()
  afterEach (done) ->
    c.inPorts.recurse.detach recurse
    c.inPorts.keep.detach keep
    c.outPorts.out.detach out
    done()

  describe 'with properties to filter', ->
    it 'should return the filtered objects', (done) ->
      expected = [
        b: 2
      ,
        b: 4
      ]
      out.on 'data', (data) ->
        chai.expect(data).to.eql expected.shift()
        done() unless expected.length

      key.post new noflo.IP 'openBracket'
      key.post new noflo.IP 'data', 'a'
      key.post new noflo.IP 'data', 'c.+'
      key.post new noflo.IP 'closeBracket'

      ins.post new noflo.IP 'data',
        a: 1
        b: 2
      ins.post new noflo.IP 'data',
        cat: 3
        b: 4

  describe 'with keep set to true', ->
    it 'should return the filtered objects', (done) ->
      c.inPorts.keep.attach keep
      expected = [
        {}
      ,
        cat: 3
      ]
      out.on 'data', (data) ->
        chai.expect(data).to.eql expected.shift()
        return if expected.length
        keep.post new noflo.IP 'data', false
        done()

      keep.post new noflo.IP 'data', true
      key.post new noflo.IP 'data', 'a.+'

      ins.post new noflo.IP 'data',
        a: 1
        b: 2
      ins.post new noflo.IP 'data',
        cat: 3
        b: 4

  describe 'recursively filtering', ->
    it 'should return the filtered key/value pair', (done) ->
      c.inPorts.recurse.attach recurse
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          x:
            b: 2
            y: {}
        recurse.post new noflo.IP 'data', false
        done()

      recurse.post new noflo.IP 'data', true
      key.post new noflo.IP 'openBracket'
      key.post new noflo.IP 'data', 'a'
      key.post new noflo.IP 'data', 'c'
      key.post new noflo.IP 'closeBracket'

      ins.post new noflo.IP 'data',
        x:
          a: 1
          b: 2
          y:
            c: 3
