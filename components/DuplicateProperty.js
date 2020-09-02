const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();

  c.inPorts = new noflo.InPorts({
    property: {
      datatype: 'all',
      required: true,
      control: true,
      description: 'property to duplicate',
    },
    separator: {
      datatype: 'string',
      default: '/',
      control: true,
      description: 'separator to use to join property',
    },
    in: {
      datatype: 'object',
      description: 'object to duplicate property on',
      required: true,
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('property', 'separator', 'in')) { return; }
    const [prop, sep, data] = Array.from(input.getData('property', 'separator', 'in'));

    const properties = {};
    const separator = (sep != null) ? sep : '/';

    if (prop) {
      if (typeof prop === 'object') {
        output.done(new Error('Property name cannot be an object'));
        return;
      }

      const propParts = prop.split('=');
      if (propParts.length > 2) {
        properties[propParts.pop()] = propParts;
      } else {
        // eslint-disable-next-line prefer-destructuring
        properties[propParts[1]] = propParts[0];
      }
    }

    if (data) {
      Object.keys(properties).forEach((newprop) => {
        const original = properties[newprop];
        if (typeof original === 'string') {
          data[newprop] = data[original];
          return;
        }

        const newValues = [];
        original.forEach((originalProp) => {
          newValues.push(data[originalProp]);
        });
        data[newprop] = newValues.join(separator);
      });

      output.sendDone(data);
    }
  });
};
