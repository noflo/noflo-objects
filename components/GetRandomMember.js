const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component();
  c.description = 'Select a random member from an array';
  c.icon = 'list';
  c.inPorts.add('in', {
    datatype: 'array',
    description: 'Array to pick a member from',
  });
  c.inPorts.add('random', {
    datatype: 'number',
    description: 'Random number to use',
  });
  c.outPorts.add('out',
    { datatype: 'all' });
  c.outPorts.add('error',
    { datatype: 'object' });

  return c.process((input, output) => {
    if (!input.hasData('in', 'random')) { return; }
    const [arr, random] = Array.from(input.getData('in', 'random'));

    if ((random < 0) || (random > 1)) {
      output.done(new Error('Random number has to be between 0 and 1'));
      return;
    }
    const selected = arr[Math.min(arr.length - 1, Math.floor(random * arr.length))];
    output.sendDone({ out: selected });
  });
};
