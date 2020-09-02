const noflo = require('noflo');

let simplify;

function simplifyObject(data) {
  const keys = Object.keys(data);
  if ((keys.length === 1) && (keys[0] === '$data')) {
    return simplify(data.$data);
  }

  const simplified = {};
  Object.keys(data).forEach((key) => {
    const value = data[key];
    simplified[key] = simplify(value);
  });
  return simplified;
}

simplify = function (data) {
  if (Array.isArray(data)) {
    if (data.length === 1) {
      return data[0];
    }
    return data;
  }
  if (typeof data !== 'object') {
    return data;
  }

  return simplifyObject(data);
};

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'Simplify an objectgi';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'all',
      description: 'Object to simplify',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'all',
      description: 'Simplified object',
    },
  });

  return c.process((input, output) => {
    const data = input.getData('in');
    output.sendDone({ out: simplify(data) });
  });
};
