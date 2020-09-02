describe('InsertProperty', () => {
  let c = null;
  let loader = null;

  before((done) => {
    loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/InsertProperty', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
      return done();
    });
  });

  describe('inPorts', () => {
    it('should include "in"', (done) => {
      chai.expect(c.inPorts.in).to.be.an('object');
      return done();
    });
    return it('should include "property"', (done) => {
      chai.expect(c.inPorts.property).to.be.an('object');
      return done();
    });
  });

  describe('outPorts', () => it('should include "out"', (done) => {
    chai.expect(c.outPorts.out).to.be.an('object');
    return done();
  }));

  return describe('data flow', () => {
    let inIn = null;
    let propertyIn = null;
    let outOut = null;

    beforeEach((done) => {
      inIn = noflo.internalSocket.createSocket();
      propertyIn = noflo.internalSocket.createSocket();
      outOut = noflo.internalSocket.createSocket();

      c.inPorts.in.attach(inIn);
      c.inPorts.property.attach(propertyIn);
      c.outPorts.out.attach(outOut);
      return done();
    });

    return describe('with input on all ports', () => it('should insert the property', (done) => {
      outOut.on('data', (data) => {
        chai.expect(data).to.deep.equal({
          test: true,
          key: 'value',
        });
        return done();
      });

      inIn.post(new noflo.IP('data', { test: true }));

      propertyIn.post(new noflo.IP('openBracket', 'key'));
      propertyIn.post(new noflo.IP('data', 'value'));
      return propertyIn.post(new noflo.IP('closeBracket', 'key'));
    }));
  });
});
