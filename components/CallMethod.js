const noflo = require('noflo');

/* eslint-disable
    prefer-spread,
*/
exports.getComponent = function () {
  const c = new noflo.Component();

  c.description = 'call a method on an object';
  c.icon = 'gear';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Object on which a method will be called',
      required: true,
    },
    method: {
      datatype: 'string',
      description: 'Name of the method to call',
      required: true,
      control: true,
    },
    arguments: {
      datatype: 'all',
      description: 'Arguments given to the method (one argument per IP)',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'all',
      description: 'Value returned by the method call',
      required: true,
    },
    error: {
      datatype: 'object',
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('method', 'in')) { return; }
    if (input.attached('arguments').length > 0) {
      if (!input.hasData('arguments')) { return; }
    }
    let args = [];

    // because we can have multiple data packets,
    // we want to get them all, and use just the data
    const argsIn = input.getStream('arguments')
      .filter((ip) => (ip.type === 'data') && (ip.data != null))
      .map((ip) => ip.data);

    args = args.concat(argsIn);
    const data = input.getData('in');
    const method = input.getData('method');

    if (!data[method]) {
      output.sendDone(new Error(`Method '${method}' not available`));
      return;
    }

    output.sendDone({
      out: data[method].apply(data, args),
    });
  });
};
