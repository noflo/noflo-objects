describe('Size component', () => {
  let c = null;
  let inIn = null;
  let out = null;
  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/Size')
      .then((instance) => {
        c = instance;
        inIn = noflo.internalSocket.createSocket();
        c.inPorts.in.attach(inIn);
      });
  });
  beforeEach((done) => {
    out = noflo.internalSocket.createSocket();
    c.outPorts.out.attach(out);
    return done();
  });
  afterEach((done) => {
    c.outPorts.out.detach(out);
    return done();
  });

  describe('given an object with 3 keys', () => it('should give back number 3', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql(3);
      return done();
    });

    return inIn.post(new noflo.IP('data', { one: 1, two: 2, three: 3 }));
  }));

  return describe('given an array with 2 values', () => it('should give back number 2', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql(2);
      return done();
    });

    return inIn.post(new noflo.IP('data', [40, 2]));
  }));
});
