test = require "noflo-test"

input =
  a: 1
  b:
    c: 2
    d: [3, 4]

test.component("objects/SetPropertyValue").
  discuss("given an object, a property p and a value 1").
    send.data("property", "p").
    send.disconnect("property").
    send.data("value", 1).
    send.disconnect("value").
    send.data("in", input).
    send.disconnect("in").
  discuss("the input object should have the property p set to 1").
    receive.data("out", { a: 1, b: { c: 2, d: [3, 4] }, p: 1 }).

  next().
  discuss("given an object, a property p and a value 'test'").
    send.data("property", "p").
    send.disconnect("property").
    send.data("value", "test").
    send.disconnect("value").
    send.data("in", input).
    send.disconnect("in").
  discuss("the input object should have the property p set to 'test'").
    receive.data("out", { a: 1, b: { c: 2, d: [3, 4] }, p: "test" }).

  next().
  discuss("given an object, a property p and a value null").
    send.data("property", "p").
    send.disconnect("property").
    send.data("value", null).
    send.disconnect("value").
    send.data("in", input).
    send.disconnect("in").
  discuss("the input object should have the property p set to null").
    receive.data("out", { a: 1, b: { c: 2, d: [3, 4] }, p: null }).

  next().
  discuss("given an object, a property p and a value 0").
    send.data("property", "p").
    send.disconnect("property").
    send.data("value", 0).
    send.disconnect("value").
    send.data("in", input).
    send.disconnect("in").
  discuss("the input object should have the property p set to 0").
    receive.data("out", { a: 1, b: { c: 2, d: [3, 4] }, p: 0 }).

  next().
  discuss("given an object, a property p and a value false").
    send.data("property", "p").
    send.disconnect("property").
    send.data("value", false).
    send.disconnect("value").
    send.data("in", input).
    send.disconnect("in").
  discuss("the input object should have the property p set to false").
    receive.data("out", { a: 1, b: { c: 2, d: [3, 4] }, p: false }).

export module
