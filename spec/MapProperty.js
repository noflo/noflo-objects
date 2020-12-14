describe('MapProperty component', () => {
  let c = null;
  let ins = null;
  let map = null;
  let out = null;

  before(() => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/MapProperty')
      .then((instance) => {
        c = instance;
      });
  });

  beforeEach((done) => {
    ins = noflo.internalSocket.createSocket();
    map = noflo.internalSocket.createSocket();
    out = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(ins);
    c.inPorts.map.attach(map);
    c.outPorts.out.attach(out);
    return done();
  });

  afterEach((done) => {
    c.outPorts.out.detach(out);
    out = null;
    return done();
  });

  describe('when instantiated', () => {
    it('should have input ports', () => chai.expect(c.inPorts.in).to.be.an('object'));
    return it('should have an output port', () => chai.expect(c.outPorts.out).to.be.an('object'));
  });

  return describe('map properties', () => {
    const o = { a: 1, b: 2, c: 3 };

    it('test no map', (done) => {
      c.inPorts.map.sockets = [];
      const output = [];

      out.on('data', (data) => output.push(data));

      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([{ a: 1, b: 2, c: 3 }]);
        return done();
      });

      return ins.post(new noflo.IP('data', o));
    });

    it('test map to letter key', (done) => {
      const output = [];
      out.on('data', (data) => output.push(data));
      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([{ d: 1, b: 2, c: 3 }]);
        return done();
      });
      map.post(new noflo.IP('data', { a: 'd' }));
      return ins.post(new noflo.IP('data', o));
    });

    it('test map to colliding key', (done) => {
      const output = [];
      out.on('data', (data) => output.push(data));
      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([{ b: [1, 2], c: 3 }]);
        return done();
      });
      map.post(new noflo.IP('data', { a: 'b' }));
      return ins.post(new noflo.IP('data', o));
    });

    it('test map to 0 key', (done) => {
      const output = [];
      out.on('data', (data) => output.push(data));
      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([{ 0: 1, b: 2, c: 3 }]);
        return done();
      });
      map.post(new noflo.IP('data', { a: 0 }));
      return ins.post(new noflo.IP('data', o));
    });

    it('test map to null key', (done) => {
      const output = [];
      out.on('data', (data) => output.push(data));
      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([{ null: 1, b: 2, c: 3 }]);
        return done();
      });
      map.post(new noflo.IP('data', { a: null }));
      return ins.post(new noflo.IP('data', o));
    });

    it('test map to undefined key', (done) => {
      const output = [];
      out.on('data', (data) => output.push(data));
      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([{ undefined: 1, b: 2, c: 3 }]);
        return done();
      });
      map.post(new noflo.IP('data', { a: undefined }));
      return ins.post(new noflo.IP('data', o));
    });

    return it('test map to false key', (done) => {
      const output = [];
      out.on('data', (data) => output.push(data));
      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([{ false: 1, b: 2, c: 3 }]);
        return done();
      });
      map.post(new noflo.IP('data', { a: false }));
      return ins.post(new noflo.IP('data', o));
    });
  });
});
