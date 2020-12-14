describe('FilterPropertyValue component', () => {
  let c = null;
  let ins = null;
  let out = null;
  let loader = null;

  before(() => {
    loader = new noflo.ComponentLoader(baseDir);
  });

  before(() => loader
    .load('objects/FilterPropertyValue')
    .then((instance) => {
      c = instance;
      ins = noflo.internalSocket.createSocket();
      c.inPorts.in.attach(ins);
      out = noflo.internalSocket.createSocket();
      c.outPorts.out.attach(out);
    }));

  afterEach((done) => {
    c.outPorts.out.detach(out);
    out = null;
    return done();
  });

  it('should have input ports', (done) => {
    chai.expect(c.inPorts.in).to.be.an('object');
    return done();
  });
  it('should have an output port', (done) => {
    chai.expect(c.outPorts.out).to.be.an('object');
    return done();
  });

  it('test default behavior', (done) => {
    const actual = [{ a: 1 }, { b: 2 }, { c: 3 }];
    const expect = [{ a: 1 }, { b: 2 }, { c: 3 }];

    out.on('data', (data) => {
      const expected = expect.shift();
      chai.expect((Object.keys(data)).length).to.equal((Object.keys(expected)).length);
      Object.keys(data).forEach((prop) => {
        const val = data[prop];
        chai.expect(val).to.equal(expected[prop]);
      });
      if (expect.length === 0) { return done(); }
    });

    ins.post(new noflo.IP('openBracket'));
    for (const a of Array.from(actual)) { ins.post(new noflo.IP('data', a)); }
    return ins.post(new noflo.IP('closeBracket'));
  });

  it('test accept via map', (done) => {
    const acc = noflo.internalSocket.createSocket();
    c.inPorts.accept.attach(acc);

    acc.post(new noflo.IP('openBracket'));
    acc.post(new noflo.IP('data', { good: true }));
    acc.post(new noflo.IP('closeBracket'));

    out.on('data', (data) => {
      chai.expect(data.good).to.equal(true);
      chai.expect(data.bar).to.equal(3);
      chai.expect(Object.keys(data).length).to.equal(2);
      return done();
    });

    ins.post(new noflo.IP('openBracket'));
    ins.post(new noflo.IP('data', { good: false, foo: 1 })); // reject
    ins.post(new noflo.IP('data', { baz: 2 })); // reject
    ins.post(new noflo.IP('data', { good: true, bar: 3 })); // accept
    return ins.post(new noflo.IP('closeBracket'));
  });

  it('test accept via pairs', (done) => {
    const acc = noflo.internalSocket.createSocket();
    c.inPorts.accept.attach(acc);

    acc.post(new noflo.IP('openBracket'));
    acc.post(new noflo.IP('data', 'food=true'));
    acc.post(new noflo.IP('data', 'good=yes'));
    acc.post(new noflo.IP('data', 'hood=1'));
    acc.post(new noflo.IP('closeBracket'));

    const expect = [['good', 'yes'], ['hood', 1], ['food', true]];

    out.on('data', (data) => {
      const exp = expect.shift();
      chai.expect(data[exp[0]]).to.equal(exp[1]);
      if (expect.length === 0) { return done(); }
    });

    ins.post(new noflo.IP('openBracket'));
    ins.post(new noflo.IP('data', { good: 'yes' })); // accept
    ins.post(new noflo.IP('data', { hood: 1 })); // accept
    ins.post(new noflo.IP('data', { good: false, foo: 1 })); // reject
    ins.post(new noflo.IP('data', { baz: 2 })); // reject
    ins.post(new noflo.IP('data', { food: true, bar: 3 })); // accept
    return ins.post(new noflo.IP('closeBracket'));
  });

  return it('test accept via regexp', (done) => {
    const reg = noflo.internalSocket.createSocket();
    c.inPorts.regexp.attach(reg);
    const acc = noflo.internalSocket.createSocket();
    c.inPorts.accept.attach(acc);

    acc.post(new noflo.IP('data', {}));
    reg.post(new noflo.IP('data', 'good=[tg]rue'));

    const expect = ['grue', true];

    out.on('data', (data) => {
      chai.expect(data.good).to.equal(expect.shift());
      chai.expect(data.bar).to.equal(3);
      chai.expect(Object.keys(data).length).to.equal(2);
      if (expect.length === 0) { return done(); }
    });

    ins.post(new noflo.IP('openBracket'));
    ins.post(new noflo.IP('data', { good: 'grue', bar: 3 })); // accept
    ins.post(new noflo.IP('data', { good: false, foo: 1 })); // reject
    ins.post(new noflo.IP('data', { baz: 2 })); // reject
    ins.post(new noflo.IP('data', { good: true, bar: 3 })); // accept
    return ins.post(new noflo.IP('closeBracket'));
  });
});
