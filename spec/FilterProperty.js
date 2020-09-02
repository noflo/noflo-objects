describe('FilterProperty component', () => {
  let c = null;
  let recurse = null;
  let keep = null;
  let key = null;
  let ins = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/FilterProperty', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
      return done();
    });
  });
  beforeEach((done) => {
    recurse = noflo.internalSocket.createSocket();
    keep = noflo.internalSocket.createSocket();
    key = noflo.internalSocket.createSocket();
    ins = noflo.internalSocket.createSocket();
    c.inPorts.key.attach(key);
    c.inPorts.in.attach(ins);
    out = noflo.internalSocket.createSocket();
    c.outPorts.out.attach(out);
    return done();
  });
  afterEach((done) => {
    c.inPorts.recurse.detach(recurse);
    c.inPorts.keep.detach(keep);
    c.outPorts.out.detach(out);
    return done();
  });

  describe('with properties to filter', () => it('should return the filtered objects', (done) => {
    const expected = [
      { b: 2 },
      { b: 4 },
    ];
    out.on('data', (data) => {
      chai.expect(data).to.eql(expected.shift());
      if (!expected.length) { return done(); }
    });

    key.post(new noflo.IP('openBracket'));
    key.post(new noflo.IP('data', 'a'));
    key.post(new noflo.IP('data', 'c.+'));
    key.post(new noflo.IP('closeBracket'));

    ins.post(new noflo.IP('data', {
      a: 1,
      b: 2,
    }));
    return ins.post(new noflo.IP('data', {
      cat: 3,
      b: 4,
    }));
  }));

  describe('with keep set to true', () => it('should return the filtered objects', (done) => {
    c.inPorts.keep.attach(keep);
    const expected = [
      {},
      { cat: 3 },
    ];
    out.on('data', (data) => {
      chai.expect(data).to.eql(expected.shift());
      if (expected.length) { return; }
      keep.post(new noflo.IP('data', false));
      return done();
    });

    keep.post(new noflo.IP('data', true));
    key.post(new noflo.IP('data', 'a.+'));

    ins.post(new noflo.IP('data', {
      a: 1,
      b: 2,
    }));
    return ins.post(new noflo.IP('data', {
      cat: 3,
      b: 4,
    }));
  }));

  return describe('recursively filtering', () => it('should return the filtered key/value pair', (done) => {
    c.inPorts.recurse.attach(recurse);
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        x: {
          b: 2,
          y: {},
        },
      });
      recurse.post(new noflo.IP('data', false));
      return done();
    });

    recurse.post(new noflo.IP('data', true));
    key.post(new noflo.IP('openBracket'));
    key.post(new noflo.IP('data', 'a'));
    key.post(new noflo.IP('data', 'c'));
    key.post(new noflo.IP('closeBracket'));

    return ins.post(new noflo.IP('data', {
      x: {
        a: 1,
        b: 2,
        y: {
          c: 3,
        },
      },
    }));
  }));
});
