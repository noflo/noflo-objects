describe('DuplicateProperty component', () => {
  let c = null;
  let ins = null;
  let property = null;
  let separator = null;
  let out = null;

  before((done) => {
    const loader = new noflo.ComponentLoader(baseDir);
    return loader.load('objects/DuplicateProperty', (err, instance) => {
      if (err) { return done(err); }
      c = instance;
      ins = noflo.internalSocket.createSocket();
      property = noflo.internalSocket.createSocket();
      separator = noflo.internalSocket.createSocket();
      out = noflo.internalSocket.createSocket();
      c.inPorts.in.attach(ins);
      c.inPorts.property.attach(property);
      c.inPorts.separator.attach(separator);
      c.outPorts.out.attach(out);
      return done();
    });
  });

  return describe('duplicate property', () => it('should duplicate property ', (done) => {
    const output = [];
    out.on('data', (data) => output.push(data));
    out.once('disconnect', () => {
      chai.expect(output).to.eql([{
        a: 'eh', b: 2, c: 3, d: 'eh',
      }]);
      return done();
    });
    separator.post(new noflo.IP('data', ','));
    property.post(new noflo.IP('data', 'a=d'));
    property.post(new noflo.IP('closeBracket'));
    ins.post(new noflo.IP('data', { a: 'eh', b: 2, c: 3 }));
    return ins.post(new noflo.IP('closeBracket'));
  }));
});
