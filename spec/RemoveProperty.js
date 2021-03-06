describe('RemoveProperty', () => {
  let c = null;

  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/RemoveProperty')
      .then((instance) => {
        c = instance;
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

    return describe('with input on all ports', () => it('should remove the property', (done) => {
      outOut.on('data', (data) => {
        chai.expect(data).to.deep.equal({ oh: 'canada' });
        return done();
      });

      propertyIn.post(new noflo.IP('openBracket'));
      propertyIn.post(new noflo.IP('data', 'test'));
      propertyIn.post(new noflo.IP('data', 'key'));
      propertyIn.post(new noflo.IP('closeBracket'));

      return inIn.post(new noflo.IP('data', {
        test: true,
        key: 'value',
        oh: 'canada',
      }));
    }));
  });
});
