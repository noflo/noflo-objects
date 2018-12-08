describe 'RemoveProperty', ->
  c = null

  before (done) ->
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/RemoveProperty', (err, instance) ->
      return done err if err
      c = instance
      done()

  describe 'inPorts', ->
    it 'should include "in"', (done) ->
      chai.expect(c.inPorts.in).to.be.an 'object'
      done()
    it 'should include "property"', (done) ->
      chai.expect(c.inPorts.property).to.be.an 'object'
      done()
  describe 'outPorts', ->
    it 'should include "out"', (done) ->
      chai.expect(c.outPorts.out).to.be.an 'object'
      done()

  describe 'data flow', ->
    inIn = null
    propertyIn = null
    outOut = null

    beforeEach (done) ->
      inIn = noflo.internalSocket.createSocket()
      propertyIn = noflo.internalSocket.createSocket()
      outOut = noflo.internalSocket.createSocket()

      c.inPorts.in.attach inIn
      c.inPorts.property.attach propertyIn
      c.outPorts.out.attach outOut
      done()

    describe 'with input on all ports', ->
      it 'should remove the property', (done) ->
        outOut.on 'data', (data) ->
          chai.expect(data).to.deep.equal
            oh: 'canada'
          done()

        propertyIn.post new noflo.IP 'openBracket'
        propertyIn.post new noflo.IP 'data', 'test'
        propertyIn.post new noflo.IP 'data', 'key'
        propertyIn.post new noflo.IP 'closeBracket'

        inIn.post new noflo.IP 'data',
          test: true
          key: 'value'
          oh: 'canada'

