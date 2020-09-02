const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'gets the size of an object and sends that out as a number';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Object to measure the size of',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'int',
      description: 'Size of the input object',
    },
  });

  return c.process((input, output) => {
    let size;
    const data = input.getData('in');

    if (typeof data === 'object') {
      size = Object.keys(data).length;
    } else {
      size = data.length;
    }

    output.sendDone({ out: size });
  });
};
