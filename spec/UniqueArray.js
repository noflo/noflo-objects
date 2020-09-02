describe('UniqueArray component', () => {
  let c = null;
  let inIn = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/UniqueArray', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
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

  return describe('given an array with 3 items, with a duplicate', () => it('should give an array with only 2', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql(['0', '1']);
      return done();
    });

    return inIn.post(new noflo.IP('data', [0, 1, 1]));
  }));
});
