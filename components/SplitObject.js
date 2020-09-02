const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'splits a single object into multiple IPs, wrapped with the key as the group';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Object to split key/values from',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'all',
      description: 'Values from the input object (one value per IP and its key sent as group)',
    },
  });

  return c.process((input, output) => {
    const data = input.getData('in');

    Object.keys(data).forEach((key) => {
      const value = data[key];
      output.send(new noflo.IP('openBracket', key));
      output.send(new noflo.IP('data', value));
      output.send(new noflo.IP('closeBracket', key));
    });

    output.done();
  });
};
