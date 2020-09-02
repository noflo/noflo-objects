const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'splits a single array into multiple IPs, wrapped with the key as the group';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Array to split from',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'all',
      description: 'Values from the split array',
    },
  });

  return c.process((input, output) => {
    const data = input.getData('in');
    if ((typeof data === 'object') && !Array.isArray(data)) {
      Object.keys(data).forEach((key) => {
        const item = data[key];
        output.send(new noflo.IP('openBracket', key));
        output.send(new noflo.IP('data', item));
        output.send(new noflo.IP('closeBracket', key));
      });
      output.done();
      return;
    }
    output.send(new noflo.IP('openBracket'));
    data.forEach((item) => {
      output.send({ out: item });
    });
    output.send(new noflo.IP('closeBracket'));
    output.done();
  });
};
