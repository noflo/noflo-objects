describe('GetRandomMember component', () => {
  let c = null;
  let ins = null;
  let random = null;
  let out = null;
  let error = null;
  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/GetRandomMember')
      .then((instance) => {
        c = instance;
        ins = noflo.internalSocket.createSocket();
        c.inPorts.in.attach(ins);
        random = noflo.internalSocket.createSocket();
        c.inPorts.random.attach(random);
      });
  });
  beforeEach(() => {
    out = noflo.internalSocket.createSocket();
    c.outPorts.out.attach(out);
    error = noflo.internalSocket.createSocket();
    return c.outPorts.error.attach(error);
  });
  afterEach(() => {
    c.outPorts.out.detach(out);
    out = null;
    c.outPorts.error.detach(error);
    return error = null;
  });

  return describe('with an array', () => {
    it('should send first member when random is 0', (done) => {
      const expected = [
        '1',
      ];
      const received = [];
      out.on('ip', (ip) => {
        switch (ip.type) {
          case 'openBracket':
            received.push('<');
            break;
          case 'data':
            received.push(JSON.stringify(ip.data));
            break;
          case 'closeBracket':
            received.push('>');
            break;
        }
        if (received.length !== expected.length) { return; }
        chai.expect(received).to.eql(expected);
        return done();
      });
      ins.send([1, 2, 3]);
      return random.send(0);
    });
    it('should send last member when random is 1', (done) => {
      const expected = [
        '3',
      ];
      const received = [];
      out.on('ip', (ip) => {
        switch (ip.type) {
          case 'openBracket':
            received.push('<');
            break;
          case 'data':
            received.push(JSON.stringify(ip.data));
            break;
          case 'closeBracket':
            received.push('>');
            break;
        }
        if (received.length !== expected.length) { return; }
        chai.expect(received).to.eql(expected);
        return done();
      });
      ins.send([1, 2, 3]);
      return random.send(1);
    });
    it('should send a member when receiving random', (done) => {
      const arr = [1, 2, 3, 4, 5];
      out.on('ip', (ip) => {
        if (ip.type !== 'data') { return; }
        chai.expect(arr).to.contain(ip.data);
        return done();
      });
      ins.send(arr);
      return random.send(Math.random());
    });
    it('should forward brackets', (done) => {
      const expected = [
        '<',
        '3',
        '>',
      ];
      const received = [];
      out.on('ip', (ip) => {
        switch (ip.type) {
          case 'openBracket':
            received.push('<');
            break;
          case 'data':
            received.push(JSON.stringify(ip.data));
            break;
          case 'closeBracket':
            received.push('>');
            break;
        }
        if (received.length !== expected.length) { return; }
        chai.expect(received).to.eql(expected);
        return done();
      });
      ins.beginGroup();
      ins.send([1, 2, 3]);
      ins.endGroup();
      return random.send(1);
    });
    return it('should send an error with out-of-range random', (done) => {
      error.on('ip', (ip) => {
        chai.expect(ip.data).to.be.an('error');
        chai.expect(ip.data.message).to.contain('has to be between');
        return done();
      });
      out.on('ip', (ip) => done(new Error(`Unexpected ${ip.type} received`)));
      ins.send([1, 2, 3]);
      return random.send(-1);
    });
  });
});
