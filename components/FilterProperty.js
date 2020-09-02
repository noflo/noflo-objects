const noflo = require('noflo');
const { deepCopy } = require('owl-deepcopy');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.icon = 'filter';
  c.description = 'Filter out some properties by matching RegExps against the keys of incoming objects';

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Object to filter properties from',
      required: true,
    },
    key: {
      datatype: 'string',
      description: 'Keys to filter (one key per IP)',
      required: true,
    },
    recurse: {
      datatype: 'boolean',
      description: '"true" to recurse on the object\'s values',
      control: true,
      default: false,
    },
    keep: {
      datatype: 'boolean',
      description: '"true" if matching properties must be kept, otherwise removed',
      control: true,
      default: false,
    },
    // Legacy mode
    accept: {
      datatype: 'all',
    },
    regexp: {
      datatype: 'all',
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
    },
  });

  c.filter = (object, keys, recurse, keep, input) => (() => {
    const result = [];
    Object.keys(object).forEach((key) => {
      const value = object[key];
      let isMatched = false;

      // the keys are filters we want to match in the object
      keys.forEach((filter) => {
        const match = key.match(filter);

        // if they match, we delete them
        const matchButDontKeep = !keep && match;
        const keepButDontMatch = keep && !match;
        if (matchButDontKeep || keepButDontMatch) {
          const o = object;
          delete o[key];
          isMatched = true;
        }
      });

      if (!isMatched && recurse && (typeof value === 'object')) {
        result.push(c.filter(value, keys, recurse, keep, input));
      } else {
        result.push(undefined);
      }
    });
    return result;
  })();

  c.keys = {};
  return c.process((input, output) => {
    let accepts; let
      regexp;
    if (input.hasStream('key')) {
      c.keys[input.scope] = input.getStream('key')
        .filter((ip) => (ip.type === 'data') && (ip.data != null))
        .map((ip) => new RegExp(ip.data, 'g'));
      output.done();
      return;
    }
    if (!input.hasData('in') || !((c.keys[input.scope] != null ? c.keys[input.scope].length : undefined) > 0)) { return; }
    if (input.attached('recurse').length > 0) { if (!input.hasData('recurse')) { return; } }
    if (input.attached('keep').length > 0) { if (!input.hasData('keep')) { return; } }

    let legacy = false;
    if (input.has('accept') || input.has('regexp')) {
      legacy = true;
      accepts = input.get('accept').data;
      regexp = input.get('regexp').data;
    }

    // because we can have multiple data packets,
    // we want to get them all, and use just the data
    const keys = c.keys[input.scope];
    let data = input.getData('in');
    const recurse = input.getData('recurse');
    let keep = input.getData('keep');
    if ((keep != null) && (typeof keep === 'object')) {
      keep = keep.pop();
    }

    if (!legacy) {
      if (typeof data === 'object') {
        data = deepCopy(data);
        c.filter(data, keys, recurse, keep, input);
        output.sendDone(data);
        return;
      }
      output.done();
    }
    // Legacy mode
    const newData = {};
    let match = false;
    Object.keys(data).forEach((property) => {
      const value = data[property];
      if (accepts.indexOf(property) !== -1) {
        newData[property] = value;
        match = true;
        return;
      }

      regexp.forEach((expression) => {
        const regex = new RegExp(expression);
        if (regex.exec(property)) {
          newData[property] = value;
          match = true;
        }
      });
    });

    if (!match) {
      output.done();
      return;
    }
    output.sendDone(newData);
  });
};
