const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component({
    description: 'Create a new Date object from string',
    icon: 'clock-o',
  });

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'string',
      description: 'A string representation of a date in RFC2822/IETF/ISO8601 format',
    },
  });

  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      description: 'A new Date object',
    },
  });

  return c.process((input, output) => {
    let date;
    if (!input.has('in')) { return; }
    const data = input.getData('in');

    if ((data === 'now') || (data === null) || (data === true)) {
      date = new Date();
    } else {
      date = new Date(data);
    }

    output.sendDone({ out: date });
  });
};
