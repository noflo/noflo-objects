describe('GetCurrentTimestamp component', () => {
  let c = null;
  let ins = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/GetCurrentTimestamp', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
      ins = noflo.internalSocket.createSocket();
      c.inPorts.in.attach(ins);
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

  return describe('given a bang', () => it('should give back a date', (done) => {
    out.on('data', (data) => {
      chai.expect(typeof data).to.eql('number');
      return done();
    });

    return ins.post(new noflo.IP('data', ''));
  }));
});
