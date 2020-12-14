const getInputObject = () => JSON.parse(JSON.stringify({
  a: 1,
  b: {
    c: 2,
    d: [3, 4],
  },
}));

describe('SetPropertyValue component', () => {
  let c = null;
  let property = null;
  let value = null;
  let ins = null;
  let out = null;
  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/SetPropertyValue')
      .then((instance) => {
        c = instance;
        property = noflo.internalSocket.createSocket();
        c.inPorts.property.attach(property);
        value = noflo.internalSocket.createSocket();
        c.inPorts.value.attach(value);
        ins = noflo.internalSocket.createSocket();
        c.inPorts.in.attach(ins);
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

  describe('given an object, a property p and value 1', () => it('should set it to the object', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        a: 1,
        b: {
          c: 2,
          d: [3, 4],
        },
        p: 1,
      });
      return done();
    });

    property.post(new noflo.IP('data', 'p'));
    value.post(new noflo.IP('data', 1));
    return ins.post(new noflo.IP('data', getInputObject()));
  }));

  describe('given an object, a property p and value "test"', () => it('should set it to the object', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        a: 1,
        b: {
          c: 2,
          d: [3, 4],
        },
        p: 'test',
      });
      return done();
    });

    property.post(new noflo.IP('data', 'p'));
    value.post(new noflo.IP('data', 'test'));
    return ins.post(new noflo.IP('data', getInputObject()));
  }));

  describe('given an object, a property p and value NULL', () => it('should set it to the object', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        a: 1,
        b: {
          c: 2,
          d: [3, 4],
        },
        p: null,
      });
      return done();
    });

    property.post(new noflo.IP('data', 'p'));
    value.post(new noflo.IP('data', null));
    return ins.post(new noflo.IP('data', getInputObject()));
  }));

  describe('given an object, a property p and value 0', () => it('should set it to the object', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        a: 1,
        b: {
          c: 2,
          d: [3, 4],
        },
        p: 0,
      });
      return done();
    });

    property.post(new noflo.IP('data', 'p'));
    value.post(new noflo.IP('data', 0));
    return ins.post(new noflo.IP('data', getInputObject()));
  }));

  return describe('given an object, a property p and value FALSE', () => it('should set it to the object', (done) => {
    out.on('data', (data) => {
      chai.expect(data).to.eql({
        a: 1,
        b: {
          c: 2,
          d: [3, 4],
        },
        p: false,
      });
      return done();
    });

    property.post(new noflo.IP('data', 'p'));
    value.post(new noflo.IP('data', false));
    return ins.post(new noflo.IP('data', getInputObject()));
  }));
});
