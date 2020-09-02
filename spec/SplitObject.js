describe('SplitObject component', () => {
  let c = null;
  let ins = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/SplitObject', (err, instance) => {
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

  return describe('given an object', () => it('should return keys as groups and values as their own IPs', (done) => {
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
    out.on('ip', (data) => {
      if ((data.type === 'openBracket') && (data.data != null)) {
        received.push(`< ${data.data}`);
      }

      if ((data.type === 'data') && (data.data != null)) {
        received.push(`DATA ${data.data}`);
      }

      if (data.type === 'closeBracket') {
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
});
