describe('Keys component', () => {
  let c = null;
  let ins = null;
  let out = null;
  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/Keys')
      .then((instance) => {
        c = instance;
        ins = noflo.internalSocket.createSocket();
        c.inPorts.in.attach(ins);
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

  return describe('given an object', () => it('should return the keys as an array', (done) => {
    const expected = [
      'a',
      'b',
    ];
    out.on('data', (data) => {
      chai.expect(data).to.equal(expected.shift());
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
