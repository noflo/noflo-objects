describe('ExtractProperty component', () => {
  let c = null;
  let key = null;
  let ins = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/ExtractProperty', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
      key = noflo.internalSocket.createSocket();
      c.inPorts.key.attach(key);
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

  const getInputObject = () => ({
    p: false,
    n: null,
  });

  return describe('given an object, a property/key p', () => {
    it('should extract the value of that property from the object', (done) => {
      out.on('data', (data) => {
        chai.expect(data).to.eql(false);
        return done();
      });

      key.post(new noflo.IP('data', 'p'));
      return ins.post(new noflo.IP('data', getInputObject()));
    });

    return it('should not extract a non existant property from the object', (done) => {
      out.on('data', (data) => {
        chai.expect(data).to.eql(null);
        return done();
      });

      key.post(new noflo.IP('data', 'z'));
      return ins.post(new noflo.IP('data', getInputObject()));
    });
  });
});
