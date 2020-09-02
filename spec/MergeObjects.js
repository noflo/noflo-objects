describe('MergeObjects component', () => {
  let c = null;
  let ins = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/MergeObjects', (err, instance) => {
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

  return describe('when receiving two objects', () => it('should produce a merged object on disconnect', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        x: 7,
        y: [2, 3, 4, 8, 9],
        z: {
          p: 10,
          q: 6,
          r: 11,
        },
      });
      return done();
    });

    ins.post(new noflo.IP('openBracket'));
    ins.post(new noflo.IP('data', {
      x: 1,
      y: [2, 3, 4],
      z: {
        p: 5,
        q: 6,
      },
    }));
    ins.post(new noflo.IP('data', {
      x: 7,
      y: [8, 9],
      z: {
        p: 10,
        r: 11,
      },
    }));
    return ins.post(new noflo.IP('closeBracket'));
  }));
});
