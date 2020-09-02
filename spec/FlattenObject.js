describe('FlattenObject component', () => {
  let c = null;
  let ins = null;
  let map = null;
  let out = null;

  before((done) => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/FlattenObject', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
      ins = noflo.internalSocket.createSocket();
      map = noflo.internalSocket.createSocket();
      out = noflo.internalSocket.createSocket();
      c.inPorts.in.attach(ins);
      c.inPorts.map.attach(map);
      c.outPorts.out.attach(out);
      return done();
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
    c.inPorts.in.detach(ins);
    c.inPorts.map.detach(map);
    c.outPorts.out.detach(out);
    return done();
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

  return describe('flatten', () => {
    const tree = {
      root: {
        branch1: ['leaf1', 'leaf2'],
        branch2: ['leaf3', 'leaf4'],
        branch3: {
          branch4: 'leaf5',
        },
      },
    };

    it('test no map', (done) => {
      c.inPorts.map.sockets = [];
      const output = [];

      out.on('data', (data) => output.push(data));

      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([
          { value: 'leaf1' },
          { value: 'leaf2' },
          { value: 'leaf3' },
          { value: 'leaf4' },
          { value: 'leaf5' },
        ]);
        return done();
      });

      return ins.post(new noflo.IP('data', tree));
    });

    it('test map depth 0', (done) => {
      const output = [];

      out.on('data', (data) => output.push(data));

      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([
          { value: 'leaf1', index: '0' },
          { value: 'leaf2', index: '1' },
          { value: 'leaf3', index: '0' },
          { value: 'leaf4', index: '1' },
          { value: 'leaf5', index: 'branch4' },
        ]);
        return done();
      });
      map.post(new noflo.IP('data', { 0: 'index' }));
      return ins.post(new noflo.IP('data', tree));
    });

    it('test map depth 1', (done) => {
      const output = [];

      out.on('data', (data) => output.push(data));

      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([
          { value: 'leaf1', branch: 'branch1' },
          { value: 'leaf2', branch: 'branch1' },
          { value: 'leaf3', branch: 'branch2' },
          { value: 'leaf4', branch: 'branch2' },
          { value: 'leaf5', branch: 'branch3' },
        ]);
        return done();
      });

      map.post(new noflo.IP('data', { 1: 'branch' }));
      return ins.post(new noflo.IP('data', tree));
    });

    it('test map depth 2', (done) => {
      const output = [];

      out.on('data', (data) => output.push(data));

      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([
          { value: 'leaf1', root: 'root' },
          { value: 'leaf2', root: 'root' },
          { value: 'leaf3', root: 'root' },
          { value: 'leaf4', root: 'root' },
          { value: 'leaf5', root: 'root' },
        ]);
        return done();
      });

      map.post(new noflo.IP('data', { 2: 'root' }));
      return ins.post(new noflo.IP('data', tree));
    });

    it('test map depth 3', (done) => {
      const output = [];

      out.on('data', (data) => output.push(data));

      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([
          { value: 'leaf1', nothere: undefined },
          { value: 'leaf2', nothere: undefined },
          { value: 'leaf3', nothere: undefined },
          { value: 'leaf4', nothere: undefined },
          { value: 'leaf5', nothere: undefined },
        ]);
        return done();
      });

      map.post(new noflo.IP('data', { 3: 'nothere' }));
      return ins.post(new noflo.IP('data', tree));
    });

    return it('test map all', (done) => {
      const output = [];

      out.on('data', (data) => output.push(data));

      out.once('disconnect', () => {
        chai.expect(output).to.deep.equal([
          {
            value: 'leaf1', index: '0', branch: 'branch1', root: 'root',
          },
          {
            value: 'leaf2', index: '1', branch: 'branch1', root: 'root',
          },
          {
            value: 'leaf3', index: '0', branch: 'branch2', root: 'root',
          },
          {
            value: 'leaf4', index: '1', branch: 'branch2', root: 'root',
          },
          {
            value: 'leaf5', index: 'branch4', branch: 'branch3', root: 'root',
          },
        ]);
        return done();
      });

      map.post(new noflo.IP('data', { 0: 'index', 1: 'branch', 2: 'root' }));
      return ins.post(new noflo.IP('data', tree));
    });
  });
});
