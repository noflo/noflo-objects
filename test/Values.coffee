test = require "noflo-test"

input =
  a: 1
  b:
    c: 2
    d: [3, 4]

test.component("objects/Values").
  discuss("given any object").
    send.data("in", input).
    send.disconnect("in").
  discuss("get the top-level values as an array").
    receive.data("out", [1, { c: 2, d: [3, 4] }]).

export module
