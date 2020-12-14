describe('GetObjectPath', () => {
  let c = null;
  let inIn = null;
  let pathIn = null;
  let multipleIn = null;
  let outOut = null;
  let objectOut = null;
  let errorOut = null;

  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/GetObjectPath')
      .then((instance) => {
        c = instance;
      });
  });

  beforeEach((done) => {
    inIn = noflo.internalSocket.createSocket();
    pathIn = noflo.internalSocket.createSocket();
    multipleIn = noflo.internalSocket.createSocket();
    objectOut = noflo.internalSocket.createSocket();
    errorOut = noflo.internalSocket.createSocket();
    outOut = noflo.internalSocket.createSocket();

    c.inPorts.in.attach(inIn);
    c.inPorts.path.attach(pathIn);
    c.inPorts.multiple.attach(multipleIn);
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

  describe('sending single values', () => {
    beforeEach(() => {
      multipleIn.post(new noflo.IP('data', false));
    });
    describe('with a JSONPath matching the input object', () => {
      it('should send the matched value out', (done) => {
        outOut.on('data', (data) => {
          chai.expect(data).to.equal(42);
          done();
        });
        errorOut.on('data', done);
        pathIn.post(new noflo.IP('data', '$.answer'));
        inIn.post(new noflo.IP('data', {
          question: undefined,
          answer: 42,
        }));
      });
    });

    describe('with a JSONPath matching a member of input array', () => {
      it('should send the matched value out', (done) => {
        outOut.on('data', (data) => {
          chai.expect(data).to.equal(42);
          done();
        });
        errorOut.on('data', done);
        pathIn.post(new noflo.IP('data', '$..[2].answer'));
        inIn.post(new noflo.IP('data', [
          {
            question: undefined,
            answer: 40,
          },
          {
            question: undefined,
            answer: 41,
          },
          {
            question: undefined,
            answer: 42,
          },
        ]));
      });
    });

    describe('with an invalid JSONPath syntax', () => {
      it('should send an error out', (done) => {
        outOut.on('data', () => {
          done(new Error('Received unexpected data'));
        });
        errorOut.on('data', (data) => {
          chai.expect(data).to.be.an('error');
          done();
        });
        pathIn.post(new noflo.IP('data', '$.[2].answer'));
        inIn.post(new noflo.IP('data', {
          question: undefined,
          answer: 40,
        }));
      });
    });
  });

  describe('sending multiple values', () => {
    beforeEach(() => {
      multipleIn.post(new noflo.IP('data', true));
    });
    describe('with a JSONPath matching the input object', () => {
      it('should send the matched value out', (done) => {
        outOut.on('data', (data) => {
          chai.expect(data).to.eql([42]);
          done();
        });
        errorOut.on('data', done);
        pathIn.post(new noflo.IP('data', '$.answer'));
        inIn.post(new noflo.IP('data', {
          question: undefined,
          answer: 42,
        }));
      });
    });

    describe('with a JSONPath matching members of input array', () => {
      it('should send the matched values out', (done) => {
        outOut.on('data', (data) => {
          chai.expect(data).to.eql([40, 41, 42]);
          done();
        });
        errorOut.on('data', done);
        pathIn.post(new noflo.IP('data', '$..answer'));
        inIn.post(new noflo.IP('data', [
          {
            question: undefined,
            answer: 40,
          },
          {
            question: undefined,
            answer: 41,
          },
          {
            question: undefined,
            answer: 42,
          },
        ]));
      });
    });
  });
});
