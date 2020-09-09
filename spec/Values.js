describe('Values component', () => {
  let c = null;
  let ins = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/Values', (err, instance) => {
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

  return describe('given an object', () => it('should return the values as an array', (done) => {
    const expected = [
      1,
      {
        c: 2,
        d: [3, 4],
      },
    ];
    out.on('data', (data) => {
      chai.expect(data).to.eql(expected.shift());
      if (!expected.length) { return done(); }
    });

    return ins.post(new noflo.IP('data', {
      a: 1,
      b: {
        c: 2,
        d: [3, 4],
      },
    }));
  }));
});