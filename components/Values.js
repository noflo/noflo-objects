const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'gets only the values of an object and forward them as an array';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'all',
      description: 'Object to extract values from',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'all',
      description: 'Values extracted from the input object (one value per IP)',
    },
  });

  return c.process((input, output) => {
    const data = input.getData('in');

    const keys = Object.keys(data);
    const values = Array(keys.length);
    for (let index = 0; index < keys.length; index += 1) {
      const key = keys[index];
      values[index] = data[key];
    }

    output.send(new noflo.IP('openBracket'));
    values.forEach((value) => {
      output.send(new noflo.IP('data', value));
    });
    output.send(new noflo.IP('closeBracket'));
    output.done();
  });
};
