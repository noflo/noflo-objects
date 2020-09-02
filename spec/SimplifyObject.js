describe('SimplifyObject component', () => {
  let c = null;
  let inIn = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/SimplifyObject', (err, instance) => {
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

  describe('given an object with a $data key', () => it('should give back the value', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.equal('value');
      return done();
    });

    return inIn.post(new noflo.IP('data', { $data: 'value' }));
  }));

  describe('given an object with a normal key', () => it('should give back the object as it was', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({ test: 'value' });
      return done();
    });

    return inIn.post(new noflo.IP('data', { test: 'value' }));
  }));

  describe('given an array with 2 items', () => it('should give back the array as it was', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql(['value', 'canada']);
      return done();
    });

    return inIn.post(new noflo.IP('data', ['value', 'canada']));
  }));

  return describe('given an array with 1 item', () => it('should give back the value', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.equal('value');
      return done();
    });

    return inIn.post(new noflo.IP('data', ['value']));
  }));
});
