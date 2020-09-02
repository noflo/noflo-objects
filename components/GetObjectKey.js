const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.icon = 'indent';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Object to get keys from',
      required: true,
    },
    key: {
      datatype: 'string',
      description: 'Keys to extract from the object (one key per IP)',
      required: true,
    },
    sendgroup: {
      datatype: 'boolean',
      description: 'true to send keys as groups around value IPs, false otherwise',
      control: true,
      default: false,
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'all',
      description: 'Values extracts from the input object given the input keys (one value per IP, potentially grouped using the key names)',
    },
    object: {
      datatype: 'object',
      description: 'Object forwarded from input if at least one property matches the input keys',
    },
    missed: {
      datatype: 'object',
      description: 'Object forwarded from input if no property matches the input keys',
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('in')) { return; }
    if (!input.hasStream('key')) { return; }
    if (input.attached('sendgroup').length > 0) { if (!input.hasData('sendgroup')) { return; } }

    const keys = input.getStream('key')
      .filter((ip) => ip.type === 'data')
      .map((ip) => ip.data);
    const data = input.getData('in');

    let sendGroup = input.getData('sendgroup');
    sendGroup = (sendGroup === 'true') || (sendGroup === true);

    if (typeof data !== 'object') {
      output.sendDone(new Error('Data is not an object'));
      return;
    }
    if (data === null) {
      output.sendDone(new Error('Data is NULL'));
      return;
    }
    keys.forEach((key) => {
      if (data[key] === undefined) {
        if (sendGroup) { output.send({ missed: new noflo.IP('openBracket', key) }); }
        output.send({ missed: new noflo.IP('data', data) });
        if (sendGroup) { output.send({ missed: new noflo.IP('closeBracket', key) }); }
      }

      if (sendGroup) { output.send({ out: new noflo.IP('openBracket', key) }); }
      output.send({ out: new noflo.IP('data', data[key]) });
      if (sendGroup) { output.send({ out: new noflo.IP('closeBracket', key) }); }
    });

    output.send({ object: new noflo.IP('data', data) });
    output.done();
  });
};
