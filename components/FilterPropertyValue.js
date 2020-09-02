const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component({
    icon: 'filter',
    description: 'Filter out some values',
  });

  c.inPorts = new noflo.InPorts({
    accept: {
      datatype: 'all',
      description: 'property value to accept, can be more than one per object',
    },
    regexp: {
      datatype: 'string',
      description: 'regex properties to accept',
    },
    in: {
      datatype: 'object',
      description: 'Object to filter properties from',
      required: true,
    },
  });

  c.outPorts = new noflo.OutPorts({
    out: {
      datatype: 'object',
      description: 'Object including the filtered properties',
    },
    missed: {
      datatype: 'object',
      description: 'Object received as input if no key have been matched',
    },
  });

  c.forwardBrackets = {};
  return c.process((input, output) => {
    let mapParts;
    if (!input.hasStream('in')) { return; }
    if (input.attached('accept').length > 0) { if (!input.hasStream('accept')) { return; } }
    if (input.attached('regexp').length > 0) { if (!input.hasData('regexp')) { return; } }

    const stream = input.getStream('in')
      .filter((ip) => ip.type === 'data')
      .map((ip) => ip.data);
    const regexps = {};
    let accepts = {};
    if (input.has('accept')) {
      const acceptData = input.getStream('accept')
        .filter((ip) => ip.type === 'data')
        .map((ip) => ip.data);

      for (let index = 0; index < acceptData.length; index += 1) {
        const accept = acceptData[index];
        if (typeof accept === 'object') {
          accepts = accept;
          break;
        }
        mapParts = accept.split('=');
        try {
          // eslint-disable-next-line no-eval
          accepts[mapParts[0]] = eval(mapParts[1]);
        } catch (e) {
          if (e instanceof ReferenceError) {
            // eslint-disable-next-line prefer-destructuring
            accepts[mapParts[0]] = mapParts[1];
          } else {
            output.sendDone(e);
            return;
          }
        }
      }
    }

    if (input.has('regexp')) {
      const regexpData = input.getStream('regexp')
        .filter((ip) => ip.type === 'data')
        .map((ip) => ip.data);

      if (regexpData.length > 0) {
        mapParts = regexpData[0].split('=');
        // eslint-disable-next-line prefer-destructuring
        regexps[mapParts[0]] = mapParts[1];
      }
    }

    stream.forEach((data) => {
      if (((Object.keys(accepts)).length > 0) || ((Object.keys(regexps)).length > 0)) {
        const newData = {};
        let match = false;
        Object.keys(data).forEach((property) => {
          const value = data[property];
          if (accepts[property]) {
            if (accepts[property] !== value) { return; }
            match = true;
          }
          if (regexps[property]) {
            const regexp = new RegExp(regexps[property]);
            if (!regexp.exec(value)) { return; }
            match = true;
          }
          newData[property] = value;
        });

        if (!match) {
          output.send({ missed: data });
        } else {
          output.send({ out: newData });
        }
      } else {
        output.send({ out: data });
      }
    });

    output.done();
  });
};
