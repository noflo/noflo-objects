const noflo = require('noflo');

// currently only accepts one map and one regex per object
exports.getComponent = function () {
  const c = new noflo.Component();

  c.inPorts = new noflo.InPorts({
    map: {
      datatype: 'all',
      description: 'Map to use to map property on object',
    },
    regexp: {
      datatype: 'string',
      description: 'Regex to use to map property on object',
    },
    in: {
      datatype: 'object',
      description: 'Object to map property on',
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

    const regexps = {};
    if (input.hasData('regexp')) {
      const regexp = input.getData('regexp');
      const regexPart = regexp.split('=');
      // eslint-disable-next-line prefer-destructuring
      regexps[regexPart[0]] = regexPart[1];
    }

    let map = {};
    if (input.hasData('map')) {
      map = input.getData('map');
      if (typeof map !== 'object') {
        const mapParts = map.split('=');
        // eslint-disable-next-line prefer-destructuring
        map[mapParts[0]] = mapParts[1];
      }
    }

    const newData = {};
    Object.keys(data).forEach((property) => {
      const value = data[property];
      let prop = property;
      if (property in map) {
        prop = map[property];
      }

      Object.keys(regexps).forEach((expression) => {
        const replacement = regexps[expression];
        const regexp = new RegExp(expression);
        const matched = regexp.exec(prop);
        if (!matched) { return; }
        prop = prop.replace(regexp, replacement);
      });

      if (prop in newData) {
        if (Array.isArray(newData[property])) {
          newData[property].push(value);
        } else {
          newData[property] = [newData[property], value];
        }
      } else {
        newData[property] = value;
      }
    });

    output.sendDone({ out: newData });
  });
};
