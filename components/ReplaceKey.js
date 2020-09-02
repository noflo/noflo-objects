const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'given a regexp matching any key of an incoming object as a data IP, replace the key with the provided string';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Object to replace a key from',
    },
    pattern: {
      datatype: 'all',
      description: 'pattern to use to replace key',
      control: true,
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      description: 'Object forwared from input',
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('in', 'pattern')) { return; }
    const data = input.getData('in');
    const patterns = input.getData('pattern');
    let newKey = null;

    Object.keys(data).forEach((key) => {
      const value = data[key];
      Object.keys(patterns).forEach((pattern) => {
        const replace = patterns[pattern];
        const regexp = new RegExp(pattern);

        if (key.match(regexp) != null) {
          newKey = key.replace(regexp, replace);
          data[newKey] = value;
          delete data[key];
        }
      });
    });

    output.sendDone({ out: data });
  });
};
