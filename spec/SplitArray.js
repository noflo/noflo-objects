describe('SplitArray component', () => {
  let c = null;
  let ins = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/SplitArray', (err, instance) => {
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

  describe('given an object (even though it is SplitArray)...', () => it('should return keys as groups and values as their own IPs', (done) => {
    const expected = [
      '< x',
      'DATA 1',
      '>',
      '< y',
      'DATA 2',
      '>',
    ];
    const received = [];

    let closing = 0;
    out.on('ip', (ip) => {
      if (ip.type === 'openBracket') {
        received.push(`< ${ip.data}`);
      }

      if (ip.type === 'data') {
        received.push(`DATA ${ip.data}`);
      }

      if (ip.type === 'closeBracket') {
        closing++;
        received.push('>');
        if (closing === 2) {
          chai.expect(received).to.eql(expected);
          return done();
        }
      }
    });

    return ins.post(new noflo.IP('data', {
      x: 1,
      y: 2,
    }));
  }));

  return describe('given an array', () => it('should return values as their own IPs', (done) => {
    const expected = [
      'DATA 1',
      'DATA 2',
    ];
    const received = [];

    out.on('ip', (ip) => {
      if (ip.type === 'data') {
        received.push(`DATA ${ip.data}`);
      }
      if (ip.type === 'closeBracket') {
        chai.expect(received).to.eql(expected);
        return done();
      }
    });

    return ins.post(new noflo.IP('data', [1, 2]));
  }));
});
