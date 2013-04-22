test = require "noflo-test"

input =
  a: 1
  b:
    c: 2
    d: [3, 4]

test.component("objects/Keys").
  discuss("given any object").
    send.data("in", input).
    send.disconnect("in").
  discuss("get the top-level keys as an array").
    receive.data("out", ["a", "b"]).

export module
