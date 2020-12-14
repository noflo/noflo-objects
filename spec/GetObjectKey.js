describe('GetObjectKey', () => {
  let c = null;

  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/GetObjectKey')
      .then((instance) => {
        c = instance;
      });
  });

  describe('inPorts', () => {
    it('should include "in"', (done) => {
      chai.expect(c.inPorts.in).to.be.an('object');
      return done();
    });
    it('should include "key"', (done) => {
      chai.expect(c.inPorts.key).to.be.an('object');
      return done();
    });
    return it('should include "sendgroup"', (done) => {
      chai.expect(c.inPorts.sendgroup).to.be.an('object');
      return done();
    });
  });

  describe('outPorts', () => {
    it('should include "out"', (done) => {
      chai.expect(c.outPorts.out).to.be.an('object');
      return done();
    });
    it('should include "object"', (done) => {
      chai.expect(c.outPorts.object).to.be.an('object');
      return done();
    });
    return it('should include "missed"', (done) => {
      chai.expect(c.outPorts.missed).to.be.an('object');
      return done();
    });
  });

  return describe('data flow', () => {
    let inIn = null;
    let keyIn = null;
    let sendgroupIn = null;
    let outOut = null;
    let objectOut = null;
    let missedOut = null;

    beforeEach((done) => {
      inIn = noflo.internalSocket.createSocket();
      keyIn = noflo.internalSocket.createSocket();
      objectOut = noflo.internalSocket.createSocket();
      missedOut = noflo.internalSocket.createSocket();
      outOut = noflo.internalSocket.createSocket();

      c.inPorts.in.attach(inIn);
      c.inPorts.key.attach(keyIn);
      c.outPorts.out.attach(outOut);
      c.outPorts.object.attach(objectOut);
      c.outPorts.missed.attach(missedOut);
      return done();
    });

    afterEach((done) => {
      c.outPorts.out.detach(outOut);
      c.outPorts.object.detach(objectOut);
      c.outPorts.missed.detach(missedOut);
      return done();
    });

    describe('with input on all ports', () => it('should get the key', (done) => {
      outOut.on('data', (data) => {
        chai.expect(data).to.eql('canada');
        return done();
      });

      objectOut.on('data', (data) => chai.expect(data).to.eql({ test: true, eh: 'canada' }));

      keyIn.post(new noflo.IP('data', 'eh'));
      return inIn.post(new noflo.IP('data', { test: true, eh: 'canada' }));
    }));

    describe('when it has data that will miss', () => it('should trigger missed and not send object out as well', (done) => {
      let triggeredOut = false;
      let triggeredMissed = false;
      outOut.on('data', () => {
        triggeredOut = true;
        if (triggeredMissed && triggeredOut) {
          return done();
        }
      });

      objectOut.on('data', () => {
        throw new Error('sent out object when it missed!');
      });

      missedOut.on('data', () => triggeredMissed = true);

      keyIn.post(new noflo.IP('data', 'nope'));
      return inIn.post(new noflo.IP('data', { test: true, eh: 'canada' }));
    }));

    return describe('when using sendgroups', () => {
      beforeEach((done) => {
        sendgroupIn = noflo.internalSocket.createSocket();
        c.inPorts.sendgroup.attach(sendgroupIn);
        return done();
      });

      it('should trigger output', (done) => {
        let hasObject = false;
        let hasBeginGroup = false;
        let hasEndGroup = false;
        let hasData = false;

        missedOut.on('data', () => {
          throw new Error('went into missed');
        });

        objectOut.on('data', (data) => {
          hasObject = true;
          return chai.expect(data).to.eql({ test: true, eh: 'canada' });
        });

        objectOut.on('disconnect', () => {
          if (hasObject && hasBeginGroup && hasData && hasEndGroup) {
            return done();
          }
        });

        outOut.on('begingroup', (data) => {
          hasBeginGroup = true;
          return chai.expect(data).to.eql('eh');
        });
        outOut.on('data', (data) => {
          hasData = true;
          return chai.expect(data).to.eql('canada');
        });
        outOut.on('endgroup', (data) => {
          hasEndGroup = true;
          return chai.expect(data).to.eql('eh');
        });

        keyIn.post(new noflo.IP('data', 'eh'));
        sendgroupIn.post(new noflo.IP('data', 'true'));
        return inIn.post(new noflo.IP('data', { test: true, eh: 'canada' }));
      });

      it('should not trigger object when it misses, but should trigger missed and out', (done) => {
        let hasMissed = false;
        let hasBeginGroup = false;
        let hasEndGroup = false;
        let hasData = false;

        missedOut.on('data', (data) => {
          hasMissed = true;
          return chai.expect(data).to.eql({ test: true, eh: 'canada' });
        });

        objectOut.on('data', () => {
          throw new Error('sent out object when it missed!');
        });

        outOut.on('begingroup', (data) => {
          hasBeginGroup = true;
          return chai.expect(data).to.eql('nonexistant');
        });
        outOut.on('data', (data) => {
          hasData = true;
          return chai.expect(data).to.not.exist;
        });
        outOut.on('endgroup', (data) => {
          hasEndGroup = true;
          chai.expect(data).to.equal('nonexistant');
          if (hasMissed && hasBeginGroup && hasData && hasEndGroup) {
            return done();
          }
        });

        keyIn.post(new noflo.IP('data', 'nonexistant'));
        sendgroupIn.post(new noflo.IP('data', 'true'));
        return inIn.post(new noflo.IP('data', { test: true, eh: 'canada' }));
      });

      it('should send groups to missed', (done) => {
        let hasMissed = false;
        let hasMissedBeginGroup = false;
        let hasMissedEndGroup = false;
        let hasBeginGroup = false;
        let hasEndGroup = false;
        let hasData = false;

        missedOut.on('connect', () => {});
        missedOut.on('disconnect', () => {});
        outOut.on('connect', () => {});
        outOut.on('disconnect', () => {});

        missedOut.on('begingroup', (data) => {
          hasMissedBeginGroup = true;
          return chai.expect(data).to.eql('nonexistant');
        });
        missedOut.on('endgroup', () => hasMissedEndGroup = true);
        missedOut.on('data', (data) => {
          hasMissed = true;
          return chai.expect(data).to.eql({ test: true, eh: 'canada' });
        });

        objectOut.on('data', () => {
          throw new Error('sent out object when it missed!');
        });

        outOut.on('begingroup', (data) => {
          hasBeginGroup = true;
          return chai.expect(data).to.eql('nonexistant');
        });
        outOut.on('data', (data) => {
          hasData = true;
          return chai.expect(data).to.not.exist;
        });
        outOut.on('endgroup', (data) => {
          hasEndGroup = true;
          chai.expect(data).to.eql('nonexistant');
          if (hasMissed
            && hasBeginGroup
            && hasData
            && hasEndGroup
            && hasMissedBeginGroup
            && hasMissedEndGroup) {
            return done();
          }
        });

        keyIn.post(new noflo.IP('data', 'nonexistant'));
        sendgroupIn.post(new noflo.IP('data', true));
        return inIn.post(new noflo.IP('data', { test: true, eh: 'canada' }));
      });

      it.skip('should be able to handle more than one key', () => {});
      it.skip('should forward brackets', () => {});
      it.skip('should forward nested brackets', () => {});
    });
  });
});
