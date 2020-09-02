describe('SetProperty component', () => {
  let c = null;
  let property = null;
  let inIn = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/SetProperty', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
      property = noflo.internalSocket.createSocket();
      c.inPorts.property.attach(property);
      inIn = noflo.internalSocket.createSocket();
      c.inPorts.in.attach(inIn);
      return done();
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

  return describe('given an empty object, property p should be set', () => it('should set it to the object', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({ p: undefined });
      return done();
    });

    inIn.post(new noflo.IP('data', {}));
    return property.post(new noflo.IP('data', 'p'));
  }));
});
