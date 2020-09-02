const noflo = require('noflo');

function merge(origin, object) {
  // Go through the incoming object
  const orig = origin;
  Object.keys(object).forEach((key) => {
    const value = object[key];
    const oValue = origin[key];

    // If property already exists, merge
    if (oValue != null) {
      // ... depending on type of the pre-existing property
      switch (toString.call(oValue)) {
        case '[object Array]':
          // Concatenate if an array
          orig[key].push.apply(origin[key], value);
          break;
        case '[object Object]':
          // Merge down if an object
          orig[key] = merge(oValue, value);
          break;
        default:
          // Replace if simple value
          orig[key] = value;
      }

      // Use object if not
    } else {
      orig[key] = value;
    }
  });
  return orig;
}

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'merges all incoming objects into one';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Objects to merge (one per IP)',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      description: 'A new object containing the merge of input objects',
    },
  });

  c.forwardBrackets = {};
  return c.process((input, output) => {
    if (!input.hasStream('in')) { return; }
    const inData = input.getStream('in')
      .filter((ip) => ip.type === 'data')
      .map((ip) => ip.data);
    output.sendDone(inData.reduce(merge, {}));
  });
};
