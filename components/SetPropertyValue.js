const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();

  c.inPorts = new noflo.InPorts({
    property: {
      datatype: 'string',
      description: 'Property name to set value on',
      required: true,
    },
    value: {
      datatype: 'all',
      description: 'Property value to set',
      required: true,
    },
    in: {
      datatype: 'object',
      description: 'Object to set property value on',
      required: true,
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      description: 'Object forwarded from the input',
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('property', 'value', 'in')) { return; }

    const data = input.getData('in');
    const property = input.getData('property');
    const value = input.getData('value');
    data[property] = value;
    output.sendDone({ out: data });
  });
};
