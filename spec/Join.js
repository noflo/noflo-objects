describe('Join', () => {
  let c = null;
  let inIn = null;
  let delimiter = null;
  let out = null;
  let errorOut = null;

  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/Join')
      .then((instance) => {
        c = instance;
      });
  });

  beforeEach((done) => {
    inIn = noflo.internalSocket.createSocket();
    delimiter = noflo.internalSocket.createSocket();
    out = noflo.internalSocket.createSocket();
    errorOut = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inIn);
    c.outPorts.out.attach(out);
    c.outPorts.error.attach(errorOut);
    return done();
  });

  afterEach((done) => {
    c.inPorts.delimiter.detach(delimiter);
    c.outPorts.out.detach(out);
    c.outPorts.error.detach(errorOut);
    return done();
  });

  return describe('Joining an object to a string', () => {
    it('should work with an object without a specified delimiter', (done) => {
      out.on('data', (data) => {
        chai.expect(data).to.eql('canada,igloo');
        return done();
      });

      return inIn.post(new noflo.IP('data', { eh: 'canada', moose: 'igloo' }));
    });

    it('should work with an object with specified delimiter', (done) => {
      c.inPorts.delimiter.attach(delimiter);
      out.on('data', (data) => {
        chai.expect(data).to.eql('canada/igloo');
        return done();
      });

      delimiter.post(new noflo.IP('data', '/'));
      return inIn.post(new noflo.IP('data', { eh: 'canada', moose: 'igloo' }));
    });

    return it('should not work with a non object', (done) => {
      errorOut.on('data', () => done());

      out.on('data', () => {
        throw new Error('should not trigger out');
      });

      return inIn.post(new noflo.IP('data', null));
    });
  });
});
