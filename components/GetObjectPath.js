const noflo = require('noflo');
const jsonpath = require('jsonpath');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.icon = 'indent';
  c.inPorts.add('in', {
    datatype: 'object',
    description: 'Object to query',
    required: true,
  });
  c.inPorts.add('path', {
    datatype: 'string',
    description: 'JSONPath expression',
    required: true,
    control: true,
  });
  c.outPorts.add('out', {
    datatype: 'all',
    description: 'Result of the JSONPath query',
  });
  c.outPorts.add('object', {
    datatype: 'all',
    description: 'The original input object',
  });
  c.outPorts.add('error', {
    datatype: 'object',
  });
  return c.process((input, output) => {
    if (!input.hasData('in', 'path')) {
      return;
    }
    const [data, path] = input.getData('in', 'path');
    let result;
    try {
      result = jsonpath.value(data, path);
    } catch (e) {
      output.done(e);
      return;
    }
    output.sendDone({
      out: result,
      object: data,
    });
  });
};
