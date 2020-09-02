const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();

  c.description = 'gets only the keys of an object and forward them as an array';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Object to get keys from',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'string',
      description: 'Keys from the incoming object (one per IP)',
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('in')) { return; }
    const data = input.getData('in');
    Object.keys(data).forEach((key) => {
      output.send({ out: new noflo.IP('data', key) });
    });
    output.done();
  });
};
