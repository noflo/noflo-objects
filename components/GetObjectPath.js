const noflo = require('noflo');
const jsonpath = require('jsonpath');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'Query an object with a JSONPath expression';
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
  c.inPorts.add('multiple', {
    datatype: 'boolean',
    description: 'Whether to send all matching values as an array',
    required: false,
    control: true,
    default: false,
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
    let multiple = false;
    if (input.attached('multiple').length > 0) {
      if (!input.hasData('multiple')) {
        return;
      }
      multiple = input.getData('multiple');
    }
    const [data, path] = input.getData('in', 'path');
    let result;
    const method = multiple ? 'query' : 'value';
    try {
      result = jsonpath[method](data, path);
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
