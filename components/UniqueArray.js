const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.icon = 'empire';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'array',
      description: 'Array to get unique values from',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'array',
      description: 'Array containing only unique values from the input array',
    },
  });

  return c.process((input, output) => {
    const data = input.getData('in');

    const seen = {};
    const newArray = [];
    data.forEach((member) => {
      seen[member] = member;
    });
    Object.keys(seen).forEach((member) => {
      newArray.push(member);
    });
    output.sendDone(newArray);
  });
};
