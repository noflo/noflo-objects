describe 'MapPropertyValue component', ->
  c = null
  ins = null
  map = null
  out = null

  before (done) ->
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/MapPropertyValue', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      map = noflo.internalSocket.createSocket()
      out = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      c.inPorts.map.attach map
      c.outPorts.out.attach out
      done()

  describe 'when instantiated', ->
    it 'should have input ports', (done) ->
      chai.expect(c.inPorts.in).to.be.an 'object'
      done()

    it 'should have an output port', (done) ->
      chai.expect(c.outPorts.out).to.be.an 'object'
      done()

  describe 'map properties', ->
    o = { a:1, b:2, c:3 }

    it 'should work with no map', (done) ->
      c.inPorts.map.sockets = []
      output = []

      out.on "data", (data) ->
        output.push data

      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [{ a:1, b:2, c:3 }]
        done()

      ins.post new noflo.IP 'data', o

    it "should map from to with object", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [ { a: 'canada', b: 2, c: 3 } ]
        done()
      map.post new noflo.IP 'data', {eh:'canada'}
      ins.post new noflo.IP 'data', { a:'eh', b:2, c:3 }

    it "should map from to with string", (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [ { a: "0", b: 2, c: 3 } ]
        done()
      map.post new noflo.IP 'data', '1=0'
      ins.post new noflo.IP 'data', o
