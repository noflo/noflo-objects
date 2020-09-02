const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component({
    inPorts: {
      start: {
        datatype: 'string',
      },
    },
    outPorts: {
      out: {
        datatype: 'object',
      },
    },
  });

  c.icon = 'bug';
  c.description = 'Create an Error object';

  c.forwardBrackets = { start: ['out'] };

  return c.process((input, output) => {
    let err;
    const data = input.getData('start');

    if (typeof data === 'string') {
      err = new Error(data);
    } else {
      err = new Error('Error');
      err.context = data;
    }

    output.sendDone({ out: err });
  });
};
