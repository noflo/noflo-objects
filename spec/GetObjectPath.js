describe.only('GetObjectPath', () => {
  let c = null;
  let inIn = null;
  let pathIn = null;
  let outOut = null;
  let objectOut = null;
  let errorOut = null;

  before((done) => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/GetObjectPath', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
      return done();
    });
  });

  beforeEach((done) => {
    inIn = noflo.internalSocket.createSocket();
    pathIn = noflo.internalSocket.createSocket();
    objectOut = noflo.internalSocket.createSocket();
    errorOut = noflo.internalSocket.createSocket();
    outOut = noflo.internalSocket.createSocket();

    c.inPorts.in.attach(inIn);
    c.inPorts.path.attach(pathIn);
    c.outPorts.out.attach(outOut);
    c.outPorts.object.attach(objectOut);
    c.outPorts.error.attach(errorOut);
    done();
  });

  afterEach((done) => {
    c.outPorts.out.detach(outOut);
    c.outPorts.object.detach(objectOut);
    c.outPorts.error.detach(errorOut);
    done();
  });

  describe('with a JSONPath matching the input object', () => {
    it('should send the matched value out', (done) => {
      outOut.on('data', (data) => {
        chai.expect(data).to.equal(42);
        done();
      });
      pathIn.post(new noflo.IP('data', '$.answer'));
      inIn.post(new noflo.IP('data', {
        question: undefined,
        answer: 42,
      }));
    });
  });
});
