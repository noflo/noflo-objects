describe 'SliceArray', ->
  c = null
  inIn = null
  begin = null
  end = null
  out = null
  errorOut = null

  before (done) ->
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/SliceArray', (err, instance) ->
      return done err if err
      c = instance
      done()

  beforeEach (done) ->
    inIn = noflo.internalSocket.createSocket()
    begin = noflo.internalSocket.createSocket()
    end = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    errorOut = noflo.internalSocket.createSocket()
    c.inPorts.in.attach inIn
    c.inPorts.begin.attach begin
    c.outPorts.out.attach out
    c.outPorts.error.attach errorOut
    done()

  afterEach (done) ->
    c.outPorts.out.detach out
    c.outPorts.error.detach errorOut
    done()

  describe 'ports', ->
    describe 'inPorts', ->
      it 'should include "in"', (done) ->
        chai.expect(c.inPorts.in).to.be.an 'object'
        done()
      it 'should include "begin"', (done) ->
        chai.expect(c.inPorts.begin).to.be.an 'object'
        done()
      it 'should include "end"', (done) ->
        chai.expect(c.inPorts.end).to.be.an 'object'
        done()
    describe 'outPorts', (done) ->
      it 'should include "out"', (done) ->
        chai.expect(c.outPorts.out).to.be.an 'object'
        done()
      it 'should include "error"', (done) ->
        chai.expect(c.outPorts.out).to.be.an 'object'
        done()

  describe 'slicing an array', ->
    it 'should not work with a non array data sent to in', (done) ->
      out.on 'data', (data) ->
        done new Error 'should not go into out'

      errorOut.on 'data', (data) ->
        chai.expect(data).to.be.an 'error'
        done()

      begin.post new noflo.IP 'data', ''
      inIn.post new noflo.IP 'data', null

    it 'should work with an array using 1 as begin', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql ['eh']
        done()

      begin.post new noflo.IP 'data', 1
      inIn.post new noflo.IP 'data', ['canada', 'eh']

    it 'should work with an array using 1 as begin and 3 as end', (done) ->
      c.inPorts.end.attach end
      out.on 'data', (data) ->
        chai.expect(data).to.eql ['eh', 'igloo']
        done()

      end.post new noflo.IP 'data', 3
      begin.post new noflo.IP 'data', 1
      inIn.post new noflo.IP 'data', ['canada', 'eh', 'igloo', 'moose', 'syrup']
