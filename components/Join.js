const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'Join all values of a passed packet together as a string with a predefined delimiter';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Object to join values from',
      required: true,
    },
    delimiter: {
      datatype: 'string',
      description: 'Delimiter to join values',
      control: true,
      default: ',',
    },
  });

  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'string',
      description: 'String conversion of all values joined with delimiter into one string',
      required: true,
    },
    error: {
      datatype: 'object',
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('in')) { return; }
    if (input.attached('delimiter').length > 0) { if (!input.hasData('delimiter')) { return; } }

    const delimiter = input.getData('delimiter' || ',');
    const data = input.getData('in');

    if ((data != null) && (typeof data === 'object')) {
      const keys = Object.keys(data);
      const {
        length,
      } = keys;
      const values = Array(length);
      for (let i = 0, end = length - 1, asc = end >= 0;
        asc ? i <= end : i >= end;
        asc ? i += 1 : i -= 1) {
        values[i] = data[keys[i]];
      }
      output.sendDone({ out: values.join(delimiter) });
      return;
    }
    output.sendDone({ error: new Error(`${typeof (data)} is not a valid object to join`) });
  });
};
