const noflo = require('noflo');

const extend = function (object, properties, other) {
  const extended = object;
  Object.keys(properties).forEach((key) => {
    const val = properties[key];
    extended[key] = val;
  });
  if (other != null) {
    Object.keys(other).forEach((key) => {
      const val = other[key];
      extended[key] = val;
    });
  }
  return extended;
};

exports.getComponent = function () {
  const c = new noflo.Component({
    description: 'Extend an incoming object to some predefined objects, optionally by a certain property',
  });

  c.inPorts = new noflo.InPorts({
    in: {
      datatype: 'object',
      description: 'Object to extend',
      required: true,
    },
    base: {
      datatype: 'object',
      description: 'Objects to extend with (one object per IP)',
      required: true,
    },
    key: {
      datatype: 'string',
      description: 'Property name to extend with',
      default: false,
      control: true,
    },
    reverse: {
      datatype: 'boolean',
      description: 'A string equal "true" if you want to reverse the order of extension algorithm',
      default: false,
      control: true,
    },
  });

  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      description: 'The object received on port "in" extended',
      required: true,
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('in')) { return; }
    if (!input.has('base')) { return; }
    if (input.attached('key').length > 0) { if (!input.hasData('key')) { return; } }
    if (input.attached('reverse').length > 0) { if (!input.hasData('reverse')) { return; } }

    let reverse = false;
    let key = input.getData('key');

    const bases = input.getStream('base')
      .filter((ip) => ip.type === 'data')
      .map((ip) => ip.data);
    const data = input.getData('in');

    if (key === undefined) {
      key = null;
    }

    // Normally, the passed IP object is extended into base objects (i.e.
    // attributes in IP object takes precendence). Pass `true` to reverse
    // would make the passed IP object the base (i.e. attributes in base
    // objects take precedence.
    reverse = String(input.getData('reverse')) === 'true';

    let out = {};
    bases.forEach((base) => {
      // Only extend when there's no key specified...
      // or when the specified attribute matches
      if ((key == null) || ((data[key] != null) && (data[key] === base[key]))) {
        out = extend(out, base);
      }
    });

    // Put on data
    if (reverse) {
      output.sendDone(extend({}, data, out));
      return;
    }
    output.sendDone(extend(out, data));
  });
};
