const noflo = require('noflo');

function mapKeys(object, maps) {
  const o = object;
  Object.keys(maps).forEach((key) => {
    const map = maps[key];
    o[map] = object.flattenedKeys[key];
  });
  delete o.flattenedKeys;
  return o;
}

function flattenObject(object) {
  const flattened = [];
  Object.keys(object).forEach((key) => {
    const value = object[key];
    if (typeof value === 'object') {
      const flattenedValue = flattenObject(value);
      flattenedValue.forEach((val) => {
        val.flattenedKeys.push(key);
        flattened.push(val);
      });
      return;
    }

    flattened.push({
      flattenedKeys: [key],
      value,
    });
  });
  return flattened;
}

exports.getComponent = function () {
  const c = new noflo.Component();

  c.inPorts = new noflo.InPorts({
    map: {
      datatype: 'all',
      description: 'map to use to flatten the object',
      control: true,
    },
    in: {
      datatype: 'object',
      description: 'Object to flatten',
      required: true,
    },
  });

  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'array',
    },
  });

  c.forwardBrackets = {};
  return c.process((input, output) => {
    if (!input.hasData('in')) { return; }
    if (input.attached('map').length > 0) { if (!input.hasData('map')) { return; } }
    let maps = {};

    if (input.hasData('map')) {
      const map = input.getData('map');
      if (map != null) {
        if (typeof map === 'object') {
          maps = map;
        } else {
          const mapParts = map.split('=');
          // eslint-disable-next-line prefer-destructuring
          maps[mapParts[0]] = mapParts[1];
        }
      }
    }

    const data = input.getData('in');
    output.send(new noflo.IP('openBracket'));
    flattenObject(data).forEach((object) => {
      output.send(mapKeys(object, maps));
    });
    output.send(new noflo.IP('closeBracket'));
    output.done();
  });
};
