describe('CallMethod component', () => {
  let c = null;
  let method = null;
  let args = null;
  let ins = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/CallMethod', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
      return done();
    });
  });
  beforeEach((done) => {
    method = noflo.internalSocket.createSocket();
    args = noflo.internalSocket.createSocket();
    ins = noflo.internalSocket.createSocket();
    c.inPorts.method.attach(method);
    c.inPorts.in.attach(ins);
    out = noflo.internalSocket.createSocket();
    c.outPorts.out.attach(out);
    return done();
  });
  afterEach((done) => {
    c.inPorts.arguments.detach(args);
    c.outPorts.out.detach(out);
    return done();
  });

  describe('with an input object', () => it('should return a value', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.equal(3);
      return done();
    });

    method.post(new noflo.IP('data', 'getA'));
    return ins.post(new noflo.IP('data', {
      a: 3,
      getA() { return this.a; },
    }));
  }));

  return describe('with arguments for method', () => it('should return the modified object', (done) => {
    c.inPorts.arguments.attach(args);
    const inc = function (forA, forB) {
      this.a += forA;
      this.b += forB;
      return this;
    };

    out.on('data', (data) => {
      chai.expect(data).to.eql({
        a: 2,
        b: 15,
        inc,
      });
      return done();
    });

    method.post(new noflo.IP('data', 'inc'));
    args.post(new noflo.IP('openBracket'));
    args.post(new noflo.IP('data', 1));
    args.post(new noflo.IP('data', 5));
    args.post(new noflo.IP('closeBracket'));
    return ins.post(new noflo.IP('data', {
      a: 1,
      b: 10,
      inc,
    }));
  }));
});
