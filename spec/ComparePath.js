describe('ComparePath', () => {
  let c = null;
  let inIn = null;
  let pathIn = null;
  let comparisonIn = null;
  let operatorIn = null;
  let passOut = null;
  let failOut = null;
  let errorOut = null;

  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/ComparePath')
      .then((instance) => {
        c = instance;
      });
  });

  beforeEach((done) => {
    inIn = noflo.internalSocket.createSocket();
    pathIn = noflo.internalSocket.createSocket();
    comparisonIn = noflo.internalSocket.createSocket();
    operatorIn = noflo.internalSocket.createSocket();
    failOut = noflo.internalSocket.createSocket();
    errorOut = noflo.internalSocket.createSocket();
    passOut = noflo.internalSocket.createSocket();

    c.inPorts.in.attach(inIn);
    c.inPorts.path.attach(pathIn);
    c.inPorts.comparison.attach(comparisonIn);
    c.inPorts.operator.attach(operatorIn);
    c.outPorts.pass.attach(passOut);
    c.outPorts.fail.attach(failOut);
    c.outPorts.error.attach(errorOut);
    done();
  });

  afterEach((done) => {
    c.outPorts.pass.detach(passOut);
    c.outPorts.fail.detach(failOut);
    c.outPorts.error.detach(errorOut);
    done();
  });

  describe('with an object containing a passing value', () => {
    it('should send the object to the PASS port', (done) => {
      const data = {
        question: undefined,
        answer: 42,
      };
      passOut.on('data', (data) => {
        chai.expect(data).to.eql(data);
        done();
      });
      failOut.on('data', () => {
        done(new Error('Received unexpected fail'));
      });
      errorOut.on('data', done);
      pathIn.send('$.answer');
      comparisonIn.send(41);
      operatorIn.send('>');
      inIn.send(data);
    });
  });
  describe('with an object containing a failing value', () => {
    it('should send the object to the FAIL port', (done) => {
      const data = {
        question: undefined,
        answer: 42,
      };
      failOut.on('data', (data) => {
        chai.expect(data).to.eql(data);
        done();
      });
      passOut.on('data', () => {
        done(new Error('Received unexpected pass'));
      });
      errorOut.on('data', done);
      pathIn.send('$.answer');
      comparisonIn.send(41);
      operatorIn.send('<');
      inIn.send(data);
    });
  });
});
