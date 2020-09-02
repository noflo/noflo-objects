const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.icon = 'clock-o';
  c.description = 'Send out the current timestamp';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'bang',
      description: 'Causes the current timestamp to be sent out',
    },
  });

  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'int',
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('in')) { return; }
    input.getData('in');
    output.sendDone({ out: Date.now() });
  });
};
