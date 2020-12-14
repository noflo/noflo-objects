describe('MapPropertyValue component', () => {
  let c = null;
  let ins = null;
  let map = null;
  let out = null;

  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/MapPropertyValue')
      .then((instance) => {
        c = instance;
        ins = noflo.internalSocket.createSocket();
        map = noflo.internalSocket.createSocket();
        out = noflo.internalSocket.createSocket();
        c.inPorts.in.attach(ins);
        c.inPorts.map.attach(map);
        c.outPorts.out.attach(out);
      });
  });

  describe('when instantiated', () => {
    it('should have input ports', (done) => {
      chai.expect(c.inPorts.in).to.be.an('object');
      return done();
    });

    return it('should have an output port', (done) => {
      chai.expect(c.outPorts.out).to.be.an('object');
      return done();
    });
  });

  return describe('map properties', () => {
    const o = { a: 1, b: 2, c: 3 };

    it('should work with no map', (done) => {
      c.inPorts.map.sockets = [];
      const output = [];

      out.on('data', (data) => output.push(data));

      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([{ a: 1, b: 2, c: 3 }]);
        return done();
      });

      return ins.post(new noflo.IP('data', o));
    });

    it('should map from to with object', (done) => {
      const output = [];
      out.on('data', (data) => output.push(data));
      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([{ a: 'canada', b: 2, c: 3 }]);
        return done();
      });
      map.post(new noflo.IP('data', { eh: 'canada' }));
      return ins.post(new noflo.IP('data', { a: 'eh', b: 2, c: 3 }));
    });

    return it('should map from to with string', (done) => {
      const output = [];
      out.on('data', (data) => output.push(data));
      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([{ a: '0', b: 2, c: 3 }]);
        return done();
      });
      map.post(new noflo.IP('data', '1=0'));
      return ins.post(new noflo.IP('data', o));
    });
  });
});
