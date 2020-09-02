const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'Insert a property into incoming objects.';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'all',
      description: 'Object to insert property into',
      required: true,
    },
    property: {
      datatype: 'all',
      description: 'Property to insert (property sent as group, value sent as IP)',
      required: true,
    },
  });

  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      description: 'Object received as input with added properties',
    },
  });
  c.forwardGroups = {};
  return c.process((input, output) => {
    if (!input.hasData('in')) { return; }
    if (!input.hasStream('property')) { return; }

    const data = input.getData('in');
    const stream = input.getStream('property');
    let val = null;
    let key = null;
    stream.forEach((ip) => {
      if (ip.type === 'openBracket') { key = ip.data; }
      if (ip.type === 'data') { val = ip.data; }
    });
    let outputData = {};
    if (data instanceof Object) {
      outputData = data;
    }

    outputData[key] = val;
    output.sendDone({ out: outputData });
  });
};
