const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();

  c.inPorts = new noflo.InPorts({
    property: {
      datatype: 'all',
      description: 'All except for object',
      required: true,
    },
    in: {
      datatype: 'object',
      description: 'Object to set property on',
      required: true,
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      description: 'Object forwared from input',
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('in', 'property')) { return; }

    const prop = input.getData('property');
    const data = input.getData('in');

    const properties = {};
    const propParts = prop.split('=');
    // eslint-disable-next-line prefer-destructuring
    properties[propParts[0]] = propParts[1];

    Object.keys(properties).forEach((property) => {
      const value = properties[property];
      data[property] = value;
    });

    output.sendDone(data);
  });
};
