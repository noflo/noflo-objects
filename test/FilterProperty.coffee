test = require "noflo-test"

test.component("objects/FilterProperty").
  discuss("set some properties to filter").
    send.connect("key").
    send.data("key", "a").
    send.data("key", "c.+").
    send.disconnect("key").
  discuss("give it some objects").
    send.connect("in").
    send.data("in", { a: 1, b: 2 }).
    send.data("in", { cat: 3, b: 4 }).
    send.disconnect("in").
  discuss("filter the said key/value pair").
    receive.data("out", { b: 2 }).
    receive.data("out", { b: 4 }).

  next().
  discuss("recursively filter the incoming object").
    send.data("recurse", "true").
  discuss("set some properties to filter").
    send.connect("key").
    send.data("key", "a").
    send.data("key", "c").
    send.disconnect("key").
  discuss("give it some objects").
    send.connect("in").
    send.data("in", { x: { a: 1, b: 2, y: { c: 3 } } }).
    send.disconnect("in").
  discuss("filter the said key/value pair").
    receive.data("out", { x: { b: 2, y: {} } }).

export module
