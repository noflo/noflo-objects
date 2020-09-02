const noflo = require('noflo');

// currently only supports one map and regex per object
exports.getComponent = function () {
  const c = new noflo.Component();

  c.inPorts = new noflo.InPorts({
    map: {
      datatype: 'all',
      description: 'Map to use to map property value on object',
    },
    regexp: {
      datatype: 'string',
      description: 'Regex to use to map property value on object',
    },
    in: {
      datatype: 'object',
      description: 'Object to map property value on',
      required: true,
    },
  });
  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      required: true,
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('in')) { return; }
    if (input.attached('regexp').length > 0) { if (!input.hasData('regexp')) { return; } }
    if (input.attached('map').length > 0) { if (!input.hasData('map')) { return; } }

    const data = input.getData('in');
    let mapAny = {};
    const map = {};
    let regexp = {};
    const regexpAny = {};

    const mapIn = input.hasData('map') ? input.getData('map') : {};
    // if it is not an object, process it...
    if (typeof mapIn !== 'object') {
      const mapParts = mapIn.split('=');
      if (mapParts.length === 3) {
        map[mapParts[0]] = {
          from: mapParts[1],
          to: mapParts[2],
        };
      } else {
        // eslint-disable-next-line prefer-destructuring
        mapAny[mapParts[0]] = mapParts[1];
      }
    // ...otherwise we keep it as an object
    } else {
      mapAny = mapIn;
    }

    const regexIn = input.hasData('regexp') ? input.getData('regexp') : {};
    if (typeof regexIn !== 'object') {
      const regexParts = regexIn.split('=');
      if (regexParts.length === 3) {
        regexp[regexParts[0]] = {
          from: regexParts[1],
          to: regexParts[2],
        };
      }
      // eslint-disable-next-line prefer-destructuring
      regexpAny[regexParts[0]] = regexParts[1];
    }

    Object.keys(data).forEach((property) => {
      // map stuff
      const value = data[property];
      if (map[property] && (map[property].from === value)) {
        data[property] = map[property].to;
      }

      if (mapAny[value]) {
        data[property] = mapAny[value];
      }

      // regex stuff
      if (regexp[property]) {
        regexp = new RegExp(regexp[property].from);
        const matched = regexp.exec(value);
        if (matched) {
          data[property] = value.replace(regexp, c.regexp[property].to);
        }
      }

      Object.keys(regexpAny).forEach((expression) => {
        const replacement = regexpAny[expression];
        regexp = new RegExp(expression);
        const matched = regexp.exec(value);
        if (!matched) { return; }
        data[property] = value.replace(regexp, replacement);
      });
    });

    output.sendDone({ out: data });
  });
};
