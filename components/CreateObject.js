const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component({ description: 'Create an empty object' });

  c.inPorts = new noflo.InPorts({
    start: {
      datatype: 'bang',
      description: 'Signal to create a new object',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      description: 'A new empty object',
    },
  });

  c.forwardBrackets = { start: ['out'] };
  return c.process((input, output) => {
    if (!input.hasData('start')) { return; }
    input.getData('start');
    output.sendDone({ out: {} });
  });
};
