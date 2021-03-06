const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component({
    description: 'Given a key, return only the value matching that key in the incoming object',
  });

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'An object to extract property from',
      required: true,
    },
    key: {
      datatype: 'string',
      description: 'Property names to extract (one property per IP)',
      required: true,
      control: true,
    },
  });

  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'all',
      description: 'Values of the property extracted (each value sent as a separate IP)',
    },
  });

  return c.process((input, output) => {
    if (!input.has('in')) { return; }
    if (!input.hasStream('key')) { return; }
    const keys = input.getStream('key')
      .filter((ip) => ip.type === 'data')
      .map((ip) => ip.data);
    const data = input.getData('in');
    let value = data;

    // Loop through the keys we have
    keys.forEach((key) => {
      value = value[key];
      // Send the extracted value
      output.send({ out: value });
    });
    output.done();
  });
};
