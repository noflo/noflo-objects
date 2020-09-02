const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'array',
      description: 'Array to slice',
      required: true,
    },
    begin: {
      datatype: 'number',
      description: 'Beginning of the slicing',
      required: true,
    },
    end: {
      datatype: 'number',
      description: 'End of the slicing',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'array',
      description: 'Result of the slice operation',
      required: true,
    },
    error: {
      datatype: 'object',
    },
  });

  return c.process((input, output) => {
    let sliced;
    if (!input.hasData('in', 'begin')) { return; }
    if (input.attached('end').length > 0) { if (!input.hasData('end')) { return; } }

    const data = input.getData('in');
    const begin = input.getData('begin');
    if (!(data != null ? data.slice : undefined)) {
      output.done(new Error(`Data ${typeof data} cannot be sliced`));
      return;
    }

    if (input.hasData('end')) {
      const end = input.getData('end');
      sliced = data.slice(begin, end);
    } else {
      sliced = data.slice(begin);
    }

    output.sendDone({ out: sliced });
  });
};
