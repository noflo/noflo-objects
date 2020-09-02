const noflo = require('noflo');

function clone(obj) {
  if ((obj === null) || (typeof obj !== 'object')) { return obj; }
  const temp = new obj.constructor();
  Object.keys(obj).forEach((key) => {
    temp[key] = clone(obj[key]);
  });
  return temp;
}

exports.getComponent = function () {
  const c = new noflo.Component();
  c.icon = 'ban';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Object to remove properties from',
      required: true,
    },
    property: {
      datatype: 'string',
      description: 'Properties to remove (one per IP)',
      required: true,
    },
  });

  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      description: 'Object forwarded from input',
    },
  });

  return c.process((input, output) => {
    let object;
    if (!input.hasData('in')) { return; }
    if (!input.hasStream('property')) { return; }
    const ip = input.get('in');
    const {
      data,
    } = ip;
    const propData = input.getStream('property')
      .filter((i) => i.type === 'data')
      .map((i) => i.data);

    // Clone the object so that the original isn't changed
    if (ip.clonable) {
      object = clone(data);
    } else {
      object = data;
    }

    propData.forEach((property) => {
      delete object[property];
    });

    output.sendDone({ out: object });
  });
};
