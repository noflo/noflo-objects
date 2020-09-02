describe('Extend component', () => {
  let c = null;
  let key = null;
  let reverse = null;
  let base = null;
  let ins = null;
  let out = null;

  const object1 = {
    a: 1,
    b: 2,
  };
  const object2 = {
    a: 3,
    c: 5,
  };
  const object3 = {
    c: 5,
    d: 6,
  };

  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/Extend', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
      return done();
    });
  });
  beforeEach((done) => {
    key = noflo.internalSocket.createSocket();
    reverse = noflo.internalSocket.createSocket();
    base = noflo.internalSocket.createSocket();
    c.inPorts.base.attach(base);
    ins = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(ins);
    out = noflo.internalSocket.createSocket();
    c.outPorts.out.attach(out);
    return done();
  });
  afterEach((done) => {
    c.inPorts.reverse.detach(reverse);
    c.inPorts.key.detach(key);
    c.outPorts.out.detach(out);
    return done();
  });

  describe('with two bases and an object to extend', () => it('should produce an object based on all three', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        a: 3,
        b: 2,
        c: 5,
        d: 6,
      });
      return done();
    });

    base.post(new noflo.IP('openBracket'));
    base.post(new noflo.IP('data', object1));
    base.post(new noflo.IP('data', object2));
    base.post(new noflo.IP('closeBracket'));

    return ins.post(new noflo.IP('data', object3));
  }));

  describe('with two bases and an empty object to extend', () => it('should produce an object based on the two', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        a: 3,
        b: 2,
        c: 5,
      });
      return done();
    });

    base.post(new noflo.IP('openBracket'));
    base.post(new noflo.IP('data', object1));
    base.post(new noflo.IP('data', object2));
    base.post(new noflo.IP('closeBracket'));

    return ins.post(new noflo.IP('data', {}));
  }));

  describe('with a "c" key for the extend', () => it('should produce an object from the only matching base and the input', (done) => {
    c.inPorts.key.attach(key);

    out.on('data', (data) => {
      chai.expect(data).to.eql({
        a: 3,
        c: 5,
        d: 6,
      });
      return done();
    });

    key.post(new noflo.IP('data', 'c'));

    base.post(new noflo.IP('openBracket'));
    base.post(new noflo.IP('data', object1));
    base.post(new noflo.IP('data', object2));
    base.post(new noflo.IP('closeBracket'));

    return ins.post(new noflo.IP('data', object3));
  }));

  describe('with key that none of the objects match', () => it('should produce an object only based on input data', (done) => {
    c.inPorts.key.attach(key);

    out.on('data', (data) => {
      chai.expect(data).to.eql({
        c: 5,
        d: 6,
      });
      return done();
    });

    key.post(new noflo.IP('data', 'norris'));

    base.post(new noflo.IP('openBracket'));
    base.post(new noflo.IP('data', object1));
    base.post(new noflo.IP('data', object2));
    base.post(new noflo.IP('closeBracket'));

    return ins.post(new noflo.IP('data', object3));
  }));

  describe('with no base objects (empty stream)', () => it('should produce an object only based on input data', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        c: 5,
        d: 6,
      });
      return done();
    });

    base.post(new noflo.IP('openBracket'));
    base.post(new noflo.IP('closeBracket'));
    return ins.post(new noflo.IP('data', object3));
  }));

  return describe('with the reverse flag set', () => it('should produce the expected object', (done) => {
    c.inPorts.reverse.attach(reverse);
    out.on('data', (data) => {
      chai.expect(data).to.eql;
      ({
        a: 3,
        b: 2,
        c: 5,
        d: 6,
      });
      return done();
    });

    reverse.post(new noflo.IP('data', 'true'));

    base.post(new noflo.IP('openBracket'));
    base.post(new noflo.IP('data', object1));
    base.post(new noflo.IP('data', object2));
    base.post(new noflo.IP('closeBracket'));

    return ins.post(new noflo.IP('data', object3));
  }));
});
