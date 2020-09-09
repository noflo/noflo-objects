/* eslint eqeqeq: 0 */
const noflo = require('noflo');
const jsonpath = require('jsonpath');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'Compare an object value extracted with a JSONPath expression';
  c.icon = 'check';
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
  c.inPorts.add('comparison', {
    datatype: 'number',
    description: 'Value to compare against',
    required: true,
    control: true,
  });
  c.inPorts.add('operator', {
    datatype: 'string',
    description: 'Comparison operator',
    control: true,
    default: '==',
    values: [
      '==',
      '!=',
      '>',
      '<',
      '>=',
      '<=',
    ],
  });
  c.outPorts.add('pass', {
    datatype: 'object',
    description: 'Object that passed the comparison',
  });
  c.outPorts.add('fail', {
    datatype: 'object',
    description: 'Object that failed the comparison',
  });
  c.outPorts.add('error', {
    datatype: 'object',
  });
  return c.process((input, output) => {
    if (!input.hasData('in', 'path', 'comparison')) {
      return;
    }
    let operator = '==';
    if (input.attached('operator').length > 0) {
      if (!input.hasData('operator')) {
        return;
      }
      operator = input.getData('operator');
    }
    const [data, path, comparison] = input.getData('in', 'path', 'comparison');
    let result;
    try {
      result = jsonpath.value(data, path);
    } catch (e) {
      output.done(e);
      return;
    }

    let passed = false;
    switch (operator) {
      case '==': {
        passed = result == comparison;
        break;
      }
      case '!=': {
        passed = result != comparison;
        break;
      }
      case '>': {
        passed = result > comparison;
        break;
      }
      case '<': {
        passed = result < comparison;
        break;
      }
      case '>=': {
        passed = result >= comparison;
        break;
      }
      case '<=': {
        passed = result <= comparison;
        break;
      }
      default: {
        output.done(new Error(`Unknown operator ${operator}`));
        return;
      }
    }
    if (passed) {
      output.sendDone({
        pass: data,
      });
      return;
    }
    output.sendDone({
      fail: data,
    });
  });
};
