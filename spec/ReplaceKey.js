describe('ReplaceKey component', () => {
  let c = null;
  let pattern = null;
  let ins = null;
  let out = null;
  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/ReplaceKey')
      .then((instance) => {
        c = instance;
        pattern = noflo.internalSocket.createSocket();
        c.inPorts.pattern.attach(pattern);
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

  return describe('given a regexp', () => it('should change the keys accordingly', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        def: 1,
        bbc: 2,
      });
      return done();
    });

    pattern.post(new noflo.IP('data',
      { 'a.+c': 'def' }));

    return ins.post(new noflo.IP('data', {
      abc: 1,
      bbc: 2,
    }));
  }));
});
